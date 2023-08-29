#include "amnezia_application.h"

#include <QClipboard>
#include <QFontDatabase>
#include <QMimeData>
#include <QStandardPaths>
#include <QTextDocument>
#include <QTimer>
#include <QTranslator>


#include "core/servercontroller.h"
#include "logger.h"
#include "version.h"
#include <QQuickStyle>

#include "platforms/ios/QRCodeReaderBase.h"

#include "ui/pages.h"

#include "ui/pages_logic/AppSettingsLogic.h"
#include "ui/pages_logic/GeneralSettingsLogic.h"
#include "ui/pages_logic/NetworkSettingsLogic.h"
#include "ui/pages_logic/NewServerProtocolsLogic.h"
#include "ui/pages_logic/QrDecoderLogic.h"
#include "ui/pages_logic/ServerConfiguringProgressLogic.h"
#include "ui/pages_logic/ServerContainersLogic.h"
#include "ui/pages_logic/ServerListLogic.h"
#include "ui/pages_logic/ServerSettingsLogic.h"
#include "ui/pages_logic/ServerContainersLogic.h"
#include "ui/pages_logic/ShareConnectionLogic.h"
#include "ui/pages_logic/SitesLogic.h"
#include "ui/pages_logic/StartPageLogic.h"
#include "ui/pages_logic/VpnLogic.h"
#include "ui/pages_logic/WizardLogic.h"

#include "ui/pages_logic/protocols/CloakLogic.h"
#include "ui/pages_logic/protocols/OpenVpnLogic.h"
#include "ui/pages_logic/protocols/ShadowSocksLogic.h"

#include "protocols/qml_register_protocols.h"

#if defined(Q_OS_IOS)
#include "platforms/ios/QtAppDelegate-C-Interface.h"
#include "platforms/ios/ios_controller.h"
#endif

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    AmneziaApplication::AmneziaApplication(int &argc, char *argv[]):
        AMNEZIA_BASE_CLASS(argc, argv)
#else
    AmneziaApplication::AmneziaApplication(int &argc, char *argv[], bool allowSecondary,
        SingleApplication::Options options, int timeout, const QString &userData):
    SingleApplication(argc, argv, allowSecondary, options, timeout, userData)
#endif
{
    setQuitOnLastWindowClosed(false);

    // Fix config file permissions
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    {
        QSettings s(ORGANIZATION_NAME, APPLICATION_NAME);
        s.setValue("permFixed", true);
    }

    QString configLoc1 = QStandardPaths::standardLocations(QStandardPaths::ConfigLocation).first() + "/"
            + ORGANIZATION_NAME + "/" + APPLICATION_NAME + ".conf";
    QFile::setPermissions(configLoc1, QFileDevice::ReadOwner | QFileDevice::WriteOwner);

    QString configLoc2 = QStandardPaths::standardLocations(QStandardPaths::ConfigLocation).first() + "/"
            + ORGANIZATION_NAME + "/" + APPLICATION_NAME + "/" + APPLICATION_NAME + ".conf";
    QFile::setPermissions(configLoc2, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
#endif

    m_settings = std::shared_ptr<Settings>(new Settings);
    m_configurator = std::shared_ptr<VpnConfigurator>(new VpnConfigurator(m_settings, this));
}

AmneziaApplication::~AmneziaApplication()
{
    if (m_engine) {
        QObject::disconnect(m_engine, 0,0,0);
        delete m_engine;
    }
    if (m_uiLogic) {
        QObject::disconnect(m_uiLogic, 0,0,0);
        delete m_uiLogic;
    }

    if (m_protocolProps) delete m_protocolProps;
    if (m_containerProps) delete m_containerProps;
}

void AmneziaApplication::init()
{
    m_engine = new QQmlApplicationEngine;
    m_uiLogic = new UiLogic(m_settings, m_configurator);

    const QUrl url(QStringLiteral("qrc:/ui/qml/main.qml"));
    QObject::connect(m_engine, &QQmlApplicationEngine::objectCreated,
                     this, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    m_engine->rootContext()->setContextProperty("Debug", &Logger::Instance());
    m_uiLogic->registerPagesLogic();

#if defined(Q_OS_IOS)
    setStartPageLogic(m_uiLogic->pageLogic<StartPageLogic>());
    IosController::Instance()->initialize();
#endif

    m_engine->load(url);

    if (m_engine->rootObjects().size() > 0) {
        m_uiLogic->setQmlRoot(m_engine->rootObjects().at(0));
    }

    if (m_settings->isSaveLogs()) {
        if (!Logger::init()) {
            qWarning() << "Initialization of debug subsystem failed";
        }
    }

#ifdef Q_OS_WIN
    if (m_parser.isSet("a")) m_uiLogic->showOnStartup();
    else emit m_uiLogic->show();
#else
    m_uiLogic->showOnStartup();
#endif

    // TODO - fix
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    if (isPrimary()) {
        QObject::connect(this, &SingleApplication::instanceStarted, m_uiLogic, [this](){
            qDebug() << "Secondary instance started, showing this window instead";
            emit m_uiLogic->show();
            emit m_uiLogic->raise();
        });
    }
#endif

// Android TextField clipboard workaround
// https://bugreports.qt.io/browse/QTBUG-113461
#ifdef Q_OS_ANDROID
    QObject::connect(qApp, &QApplication::applicationStateChanged, [](Qt::ApplicationState state) {
        if (state == Qt::ApplicationActive) {
            if (qApp->clipboard()->mimeData()->formats().contains("text/html")) {
                QTextDocument doc;
                doc.setHtml(qApp->clipboard()->mimeData()->html());
                qApp->clipboard()->setText(doc.toPlainText());
            }
        }
    });
#endif
}

void AmneziaApplication::registerTypes()
{
    qRegisterMetaType<VpnProtocol::VpnConnectionState>("VpnProtocol::VpnConnectionState");
    qRegisterMetaType<ServerCredentials>("ServerCredentials");

    qRegisterMetaType<DockerContainer>("DockerContainer");
    qRegisterMetaType<TransportProto>("TransportProto");
    qRegisterMetaType<Proto>("Proto");
    qRegisterMetaType<ServiceType>("ServiceType");
    qRegisterMetaType<Page>("Page");
    qRegisterMetaType<VpnProtocol::VpnConnectionState>("ConnectionState");

    qRegisterMetaType<PageProtocolLogicBase *>("PageProtocolLogicBase *");


    declareQmlPageEnum();
    declareQmlProtocolEnum();
    declareQmlContainerEnum();

    qmlRegisterType<PageType>("PageType", 1, 0, "PageType");
    qmlRegisterType<QRCodeReader>("QRCodeReader", 1, 0, "QRCodeReader");

    m_containerProps = new ContainerProps;
    qmlRegisterSingletonInstance("ContainerProps", 1, 0, "ContainerProps", m_containerProps);

    m_protocolProps = new ProtocolProps;
    qmlRegisterSingletonInstance("ProtocolProps", 1, 0, "ProtocolProps", m_protocolProps);
}

void AmneziaApplication::loadFonts()
{
    QQuickStyle::setStyle("Basic");

    QFontDatabase::addApplicationFont(":/fonts/Lato-Black.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-BlackItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-BoldItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-Italic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-Light.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-LightItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-Thin.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Lato-ThinItalic.ttf");
}

void AmneziaApplication::loadTranslator()
{
    m_translator = new QTranslator;
    if (m_translator->load(QLocale(), QString("amneziavpn"), QLatin1String("_"), QLatin1String(":/translations"))) {
        installTranslator(m_translator);
    }
}

bool AmneziaApplication::parseCommands()
{
    m_parser.setApplicationDescription(APPLICATION_NAME);
    m_parser.addHelpOption();
    m_parser.addVersionOption();

    QCommandLineOption c_autostart {{"a", "autostart"}, "System autostart"};
    m_parser.addOption(c_autostart);

    QCommandLineOption c_cleanup {{"c", "cleanup"}, "Cleanup logs"};
    m_parser.addOption(c_cleanup);

    m_parser.process(*this);

    if (m_parser.isSet(c_cleanup)) {
        Logger::cleanUp();
        QTimer::singleShot(100, this, [this]{
            quit();
        });
        exec();
        return false;
    }
    return true;
}

QQmlApplicationEngine *AmneziaApplication::qmlEngine() const
{
    return m_engine;
}

