#pragma once
#include <stdint.h>
#include <string>
#include <stdio.h>
//#include <process.h>
#include <assert.h>
//#include <crtdbg.h>
#include <locale.h>
#include <time.h>
//#include <tchar.h>
//#include <io.h>
using namespace std;
//#include <windows.h>
#define SERVICE_CONTROL_START_TODESK     0x00000070			//����ToDesk
#define MSG_LOCAL_CONN_CONNERR				WM_USER+901		//��������ʧ��
#define MSG_LOCAL_SESSION_CONNERR			WM_USER+902		//��������ʧ��
#define MSG_LOCAL_SESSION_CAPERR			WM_USER+903		//��������ʧ��
#define MSG_LOCAL_FTPClIP_CONNERR			WM_USER+904		//����FtpClip����ʧ��

#define MSG_CENTER_CONN_CONNERR				WM_USER+1001	//��������������ʧ��
#define MSG_CENTER_CONN_AUTHERR				WM_USER+1002	//������������֤ʧ��
#define MSG_CENTER_CONN_AUTHOK				WM_USER+1003	//������������֤�ɹ�
#define MSG_CENTER_CONN_CONN				WM_USER+1004	//��������������ID ����
#define MSG_CENTER_CONN_CONNREQ				WM_USER+1005	//��������������ID ����
#define MSG_CENTER_CONN_CONNRSP				WM_USER+1006	//��������������ID ����

#define MSG_CENTER_CONN_FILECONN			WM_USER+1007	//�����������ļ�����ID����
#define MSG_CENTER_CONN_FILECONNREQ			WM_USER+1008	//�����������ļ�����ID����

#define MSG_CENTER_CONN_CMDCONN				WM_USER+1009	//����������CMD����ID����

#define MSG_CENTER_CONN_CONNREQ_ERROR		WM_USER+1012	//��������������ID������Ϣ


#define MSG_TRANSIT_CONN_CONNERR			WM_USER+1111	//��ת����������ʧ��
#define MSG_TRANSIT_CONN_AUTHERR			WM_USER+1112	//��ת��������֤ʧ��
#define MSG_TRANSIT_CONN_AUTHOK				WM_USER+1113	//��ת��������֤�ɹ�
#define MSG_TRANSIT_FILECONN_CONNERR		WM_USER+1114	//��ת�ļ�����������ʧ��
#define MSG_TRANSIT_FILECONN_AUTHERR		WM_USER+1115	//��ת�ļ���������֤ʧ��
#define MSG_TRANSIT_FILECONN_AUTHOK			WM_USER+1116	//��ת�ļ���������֤�ɹ�
#define MSG_TRANSIT_CMDCONN_CONNERR			WM_USER+1117	//��תCMD����������ʧ��
#define MSG_TRANSIT_CMDCONN_AUTHERR			WM_USER+1118	//��תCMD��������֤ʧ��
#define MSG_TRANSIT_CMDCONN_AUTHOK			WM_USER+1119	//��תCMD��������֤�ɹ�

#define MSG_CLIENT_CONN_CONNERR				WM_USER+1221	//���ƶ�����ʧ��
#define MSG_CLIENT_CONN_AUTHERR				WM_USER+1222	//���ƶ���֤ʧ��
#define MSG_CLIENT_CONN_AUTHOK				WM_USER+1223	//���ƶ���֤ʧ��
#define MSG_CLIENT_CONN_AUTH				WM_USER+1224	//���ƶ���֤��������
#define MSG_CLIENT_FILECONN_CONNERR			WM_USER+1225	//�ļ����ƶ��ļ�����ʧ��
#define MSG_CLIENT_FILECONN_AUTHERR			WM_USER+1226	//�ļ����ƶ��ļ���֤ʧ��
#define MSG_CLIENT_FILECONN_AUTHOK			WM_USER+1227	//�ļ����ƶ��ļ���֤�ɹ�
#define MSG_CLIENT_FILECONN_AUTH			WM_USER+1228	//�ļ����ƶ���֤��������
#define MSG_CLIENT_CMDCONN_CONNERR			WM_USER+1229	//CMD���ƶ�����ʧ��
#define MSG_CLIENT_CMDCONN_AUTHERR			WM_USER+1230	//CMD���ƶ���֤ʧ��
#define MSG_CLIENT_CMDCONN_AUTHOK			WM_USER+1231	//CMD���ƶ���֤�ɹ�
#define MSG_CLIENT_CMDCONN_AUTH				WM_USER+1232	//CMD���ƶ���֤��������

#define MSG_HOST_CONN_CONNERR				WM_USER+1331	//���ض�����ʧ��
#define MSG_HOST_CONN_AUTHERR				WM_USER+1332	//���ض���֤ʧ��
#define MSG_HOST_CONN_AUTHOK				WM_USER+1333	//���ض���֤ʧ��
#define MSG_HOST_FILECONN_CONNERR			WM_USER+1334	//�ļ����ض�����ʧ��
#define MSG_HOST_FILECONN_AUTHERR			WM_USER+1335	//�ļ����ض���֤ʧ��
#define MSG_HOST_FILECONN_AUTHOK			WM_USER+1336	//�ļ����ض���֤ʧ��
#define MSG_HOST_CMDCONN_CONNERR			WM_USER+1337	//cmd���ض�����ʧ��
#define MSG_HOST_CMDCONN_AUTHERR			WM_USER+1338	//cmd���ض���֤ʧ��
#define MSG_HOST_CMDCONN_AUTHOK				WM_USER+1339	//cmd���ض���֤ʧ��
#define MSG_HOST_CLIENTCONN_BREAK			WM_USER+1340	//���ƶ����ӶϿ�	

#define MSG_FILE_CONN_STATUS				WM_USER+1441	//�ļ�ϵͳ����״̬
#define MSG_FILETRANS_STATUS				WM_USER+1442	//�ļ�����״̬
#define MSG_FILETRANS_PROGRESS				WM_USER+1443	//�ļ��������
#define MSG_FILE_CONN_DISCONN				WM_USER+1444	//�ļ��������ӶϿ�
#define MSG_FILE_CONN_CONNOK				WM_USER+1445	//�ļ����佨������

#define MSG_FILETRANS_STATUS_FINISH			WM_USER+1446	//�ļ�����״̬

#define MSG_FILETRANS_UPLOAD_START			WM_USER+1448	//�ļ����� ��ʼ�ϴ�
#define MSG_FILETRANS_UPLOADOK				WM_USER+1449	//�ļ����� �ϴ��ɹ�
#define MSG_FILETRANS_UPLOADERR				WM_USER+1450	//�ļ����� �ϴ�ʧ��

#define MSG_FILETRANS_DOWNLOAD_START		WM_USER+1451	//�ļ����� ��ʼ����
#define MSG_FILETRANS_DOWNLOADOK			WM_USER+1452	//�ļ����� ���سɹ�
#define MSG_FILETRANS_DOWNLOADERR			WM_USER+1453	//�ļ����� ����ʧ��

#define MSG_FILETRANS_DELETEOK				WM_USER+1454	//�ļ����� ɾ���ɹ�
#define MSG_FILETRANS_DELETEERR				WM_USER+1455	//�ļ����� ɾ��ʧ��

#define MSG_FILETRANS_CREATEDIR_OK			WM_USER+1456	//�ļ����� �����ļ��гɹ�
#define MSG_FILETRANS_CREATEDIR_ERR			WM_USER+1457	//�ļ����� �����ļ���ʧ��

#define MSG_FILETRANS_RENAME_OK				WM_USER+1458	//�ļ����� �������ɹ�
#define MSG_FILETRANS_RENAME_ERR			WM_USER+1459	//�ļ����� ������ʧ��


#define MSG_FILETRANS_SIZELIMIT				WM_USER+1460	//�ļ����� �������ƴ�С
#define MSG_FILETRANS_CLOSE					WM_USER+1461	//�ļ����� �����ر�

#define MSG_FILETRANS_QUEUEERR				WM_USER+1462	//�ļ����� �����쳣
#define MSG_FILETRANS_CANCEL				WM_USER+1463	//�ļ����� ȡ������
#define MSG_FILETRANS_START					WM_USER+1464	//�ļ����� ��ʼ����

#define MSG_FILETRANS_SAMEFILE_UPLOAD		WM_USER+1465	//�ļ����� �ļ���ͬʱ��ʾ
#define MSG_FILETRANS_SAMEFILE_DOWNLOAD		WM_USER+1466	//�ļ����� �ļ���ͬʱ��ʾ

#define MSG_CMDDLG_CLOSE					WM_USER+1480	//�ر�CMD����

#define	MSG_REG_PHONE_OK					WM_USER+1561	//����ע����֤��OK
#define	MSG_REG_PHONE_ERROR					WM_USER+1562	//����ע����֤��ʧ��
#define MSG_REG_PHONE_TIMER					WM_USER+1563	//����ע���뵹��ʱ ��ʱ��
#define	MSG_REG_USER_OK						WM_USER+1565	//�ֻ�ע��ɹ�
#define	MSG_REG_USER_ERROR					WM_USER+1566	//�ֻ�ע��ʧ��
#define	MSG_LOGIN_USER_RESULT				WM_USER+1567	//�ֻ���¼�ɹ�
#define	MSG_LOGIN_UPDATE_DLG				WM_USER+1569	//�ֻ���¼�ɹ�֪ͨ���½���
#define MSG_EDIT_GROUP_RESULT				WM_USER+1570	//�������鷵�ؽ��
#define MSG_EDIT_DEVICE_RESULT				WM_USER+1571	//�������鷵�ؽ��
#define MSG_GROUP_UPDATE_DLG				WM_USER+1572	//������½��
#define MSG_CLIPFILE_UPDATE					WM_USER+1573	//���а��ļ�����
#define MSG_WALLPAPER						WM_USER+1574	//ǽֽ��Ϣ

#define MSG_CLIPBOARD_TYPE					WM_USER+1575	//���а�����ͬ��
#define MSG_CLIPBOARD_TYPEREQUEST			WM_USER+1576	//���а�����ͬ��
#define MSG_CLIPBOARD_TYPEREQUESTDATA		WM_USER+1577	//���а�����ͬ��

#define MSG_NICKNAME_UPDATE					WM_USER+1581	//�ǳƸ���
#define MSG_DEVICE_UPDATE					WM_USER+1582	//���������߸���
#define MSG_ACTION_RESULT					WM_USER+1583	//Զ�̲�������ظ�


#define	MSG_CHANGE_PASSWORD_OK				WM_USER+1590	//�ֻ��޸�����ɹ�
#define	MSG_CHANGE_PASSWORD_ERROR			WM_USER+1591	//�ֻ��޸�����ʧ��
#define MSG_SHOW_FPS						WM_USER+1600	//��ʾ֡��
#define MSG_FRAMESIZE_CHANGED				WM_USER+1601	//֡��С�ı�

#define MSG_CHAT_MSG						WM_USER+1610	//������Ϣ
#define MSG_SETTING_MSG						WM_USER+1612	//������Ϣ
#define MSG_INPUTBLOCK_RESULT_MSG			WM_USER+1613	//��ֹԶ����������Ϣ

#define MSG_CMDINFO_MSG						WM_USER+1620	//CMD �����Ϣ

#define TIMER_RECONN_CENTER					1001			//����������������ʱ��
#define TIMER_HEARTBEAT						1002			//������ʱ��
#define TIMER_AUTO_HIDE						1003			//�Զ�������ʾ��
#define TIMER_AUTO_SHOWEDIT					1004			//�Զ�������ʾ��
#define TIMER_DELAY_DELETE_ITEM				1005			//�Զ�������ʾ��
#define TIMER_UPDATE_PASSWORD				1006			//��ʱ��������
#define TIMER_DELAY_DELETE_LOCALPATH		1007			//�Զ�������ʾ��
#define TIMER_DELAY_DELETE_REMOTEPATH		1008			//�Զ�������ʾ��
#define TIMER_CHECK_UPDATE					1009			//��ʱ���汾��
#define TIMER_DELAY_SETFOCUS				1010			//��ʱ�������뽹��
#define TIMER_TRAY_CHECK					1011			//�������
#define TIMER_SHOW_SPEED					1012			//��ʱ�����ļ������ٶ�
#define TIMER_DELAY_LAUNCH_SERVICE			1013			//��ʱ��������

//ui�Զ�����Ϣ
#define MSG_FILEITEM_DBCLICK				WM_USER+3001	//�ļ��б�˫����Ϣ
#define MSG_DROPFILES						WM_USER+3002	//�ļ���ק��Ϣ
#define MSG_PASTE_FILES						WM_USER+3003	//�ļ����а�ճ����Ϣ
#define MSG_PASTE_REMOTEFILES				WM_USER+3004	//�ļ����а�ճ����Ϣ

#define MSG_CONN_MODE_CHANGED				WM_USER+3010	//�ļ��б�˫����Ϣ
#define MSG_CONN_RECT_CHANGED				WM_USER+3011	//�ļ��б�˫����Ϣ


#define MSG_SHOW_TIPTEXT					WM_USER+3013	//�ļ��б�˫����Ϣ

#define MSG_TRAY_MENU						WM_USER+3014	//������Ϣ
#define MSG_TRAY_MENU_CLOSE					WM_USER+3015	//�˳���Ϣ
#define MSG_SHOW_MAINWINDOW					WM_USER+3016	//��ʾ��������Ϣ

#define MSG_CHOOSEDEVICE					WM_USER+3017	//ѡ���豸ID��Ϣ

#define MSG_CONNMNG_CLOSE_ALL				WM_USER+3021	//�ļ��б�˫����Ϣ
#define MSG_CONNMNG_CLOSE_CONN				WM_USER+3022	//�ļ��б�˫����Ϣ

#define MSG_SEND_CAD						WM_USER+3100	//����cad����
#define MSG_SEND_LOGOFF						WM_USER+3101	//����ע������
#define MSG_SEND_LOCK						WM_USER+3102	//����������������
#define MSG_SEND_REBOOT						WM_USER+3103	//������������
#define MSG_SEND_SESSION_END_LOCK			WM_USER+3104	//����������������
#define MSG_ACTIONMENU_KILLFOCUS			WM_USER+3105	//����������������
#define MSG_VIEWMENU_KILLFOCUS				WM_USER+3106	//����������������
#define MSG_WND_KILLFOCUS					WM_USER+3107	//����ʧȥ������Ϣ
#define MSG_PLAY_VOICE						WM_USER+3108	//�����Ƿ�������
#define MSG_SEND_SHUTDOWN					WM_USER+3109	//���͹ػ�����
#define MSG_SEND_CHANGEMARK					WM_USER+3110	//�����޸ı�ע����
#define MSG_SEND_UPDATESCREENLIST			WM_USER+3111	//���ͱ�����Ļ�����仯����
#define MSG_SEND_REMOTEINPUTBLOCK			WM_USER+3112	//���ͱ��ؽ�ֹ��������

#define MSG_APP_HAS_NEW_VERSION				WM_USER+3201	//���°汾����

#define MSG_FILETRAN_CLICK					WM_USER+3203	//�ļ��������¼�
#define MSG_FULLSCREEN_CLICK				WM_USER+3204	//ȫ������¼�
#define MSG_MACTHSCREEN_CLICK				WM_USER+3205	//ƥ����ѷֱ���
#define MSG_STRETCHMODE_CLICK				WM_USER+3206	//����ģʽ
#define MSG_ZOOMMODE_CLICK					WM_USER+3207	//����ģʽ
#define MSG_SCREEN_MIN						WM_USER+3208	//��С��

#define MSG_FILETRANS_ALREADY_EXIST			WM_USER+3308
#define MSG_SHOW_TRANSTYPE					WM_USER+3309
#define MSG_HOST_P2PCONN_CONNERR			WM_USER+3310	//���ض�����ʧ��

#define MSG_FTP_GET_START					WM_USER+3311
#define MSG_FTP_GET_END						WM_USER+3312
#define MSG_FTP_SET_FILEINFO				WM_USER+3313

#define MSG_CONNECT_TIP					WM_USER+3314	//���ض����Ӻ���ʾ����������ʾ��Ϣ

#define	MSG_PROXY_CHECKRESULT				WM_USER+3400	//���proxy�����Ϣ
#define	MSG_IMAGE_QUALITY_UPDATED			WM_USER+3401	//�����ȱ仯��Ϣ

#define	MSG_DETECTVOICE						WM_USER+3402	//���������Ϣ
#define	MSG_HOST_FILE_OPER_TIP				WM_USER+3403	//���ض˱����ض��ļ�����ʱ ��ʾ���ض˵��ļ��������
#define MSG_SHOW_FILETRANSDLG				WM_USER+3404	//��ʾ�ļ����䴰��
