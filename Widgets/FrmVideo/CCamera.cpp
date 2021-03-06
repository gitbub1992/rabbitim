#include "CCamera.h"
#include "../../Global.h"
#include "FrmVideo.h"
#include <QCameraInfo>

CCamera::CCamera(QObject *parent) : QObject(parent)
{
    if(!parent)
        LOG_MODEL_ERROR("Video", "CCaptureVideoFrame::CCaptureVideoFrame parent is null");

    CFrmVideo* pFrmVideo = (CFrmVideo*)parent;
    if(pFrmVideo)
        m_CaptureFrameProcess.moveToThread(pFrmVideo->GetVideoThread());

    m_pCamera = NULL;

    SetDefaultCamera();

    bool check = true;
    check = connect(&m_CaptureVideoFrame,
                    SIGNAL(sigRawCaptureFrame(const QVideoFrame&)),
                    &m_CaptureFrameProcess,
                    SLOT(slotCaptureFrame(const QVideoFrame&)));
    Q_ASSERT(check);

    check = connect(&m_CaptureFrameProcess,
                    SIGNAL(sigCaptureFrame(const QVideoFrame&)),
                    this,
                    SIGNAL(sigCaptureFrame(const QVideoFrame&)));
    Q_ASSERT(check);

    //捕获的帧转换成了YUV4:2:0格式  
    check = connect(&m_CaptureFrameProcess,
                    SIGNAL(sigConvertedToYUYVFrame(const QXmppVideoFrame&)),
                    this,
                    SIGNAL(sigConvertedToYUYVFrame(const QXmppVideoFrame&)));
    Q_ASSERT(check);
}

CCamera::~CCamera()
{
    Stop();
}

int CCamera::Start()
{
    if(m_pCamera)
    {
        Stop();
    }

    m_pCamera = new QCamera(m_CameraPosition);
    if(!m_pCamera)
    {
        LOG_MODEL_WARNING("Video", "Open carmera fail");
        return -1;
    }

    m_pCamera->setCaptureMode(QCamera::CaptureVideo);
    m_CaptureVideoFrame.setSource(m_pCamera);

    connect(m_pCamera, SIGNAL(stateChanged(QCamera::State)), SLOT(updateCameraState(QCamera::State)));
    connect(m_pCamera, SIGNAL(error(QCamera::Error)), SLOT(displayCameraError(QCamera::Error)));

    m_pCamera->start();
    return 0;
}

int CCamera::Stop()
{
    if(m_pCamera)
    {
        m_pCamera->stop();
        m_pCamera->disconnect(this);
        delete m_pCamera;
        m_pCamera = NULL;
    }
    return 0;
}

int CCamera::SetDefaultCamera()
{
#ifdef ANDROID
    QList<QByteArray> device = QCamera::availableDevices();
    QList<QByteArray>::iterator it;
    for(it = device.begin(); it != device.end(); it++)
    {
        LOG_MODEL_DEBUG("Video", "Camera:%s", qPrintable(QCamera::deviceDescription(*it)));
        QCameraInfo info(*it);
        if(info.position() == QCamera::FrontFace)
        {
            m_CameraPosition = *it;
            break;
        }
    }
#else
    if (!QCamera::availableDevices().isEmpty())
        m_CameraPosition = *(QCamera::availableDevices().begin());
#endif
    return 0;
}

void CCamera::updateCameraState(QCamera::State state)
{
    LOG_MODEL_DEBUG("CaptureVideo", "CCamera::updateCameraState:%d", state);
}

void CCamera::displayCameraError(QCamera::Error e)
{
    LOG_MODEL_DEBUG("CaptureVideo", "CCamera::updateCameraState:%d", e);
}

QList<QString> CCamera::GetAvailableDevices()
{
    QList<QString> ret; 
    QList<QByteArray> device = QCamera::availableDevices();
    QList<QByteArray>::iterator it;
    for(it = device.begin(); it != device.end(); it++)
    {
        LOG_MODEL_DEBUG("Video", "Camera:%s", qPrintable(QCamera::deviceDescription(*it)));
        ret << QCamera::deviceDescription(*it);
    }
    return ret;
}

#ifdef ANDROID
QCamera::Position CCamera::GetCameraPoistion()
{
    QCameraInfo info(m_CameraPosition);
    return info.position();
}
#endif

int CCamera::SetDeviceIndex(int index)
{
    LOG_MODEL_DEBUG("Video", "CCamera::SetDeviceIndex:%d", index);
    if(QCamera::availableDevices().isEmpty())
    {
        LOG_MODEL_ERROR("Video", "There isn't Camera");
        return -1;
    }

    if(!(QCamera::availableDevices().length() > index))
    {
        LOG_MODEL_ERROR("Video", "QCamera.availableDevices().length() > index");
        return -2;
    }

    m_CameraPosition = QCamera::availableDevices().at(index);

    return 0;
}

int CCamera::GetDeviceIndex()
{
    QList<QByteArray> device = QCamera::availableDevices();
    QList<QByteArray>::iterator it;
    int i = 0;
    for(it = device.begin(); it != device.end(); it++)
    {
        LOG_MODEL_DEBUG("Video", "Camera:%s, m_CameraPosition:%s",
                        qPrintable(QCamera::deviceDescription(*it)),
                        qPrintable(QCamera::deviceDescription(m_CameraPosition)));
        if(*it == m_CameraPosition)
            return i;
        i++;
    }
    return -1;
}

