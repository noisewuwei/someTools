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
#define SERVICE_CONTROL_START_TODESK     0x00000070			//启动ToDesk
#define MSG_LOCAL_CONN_CONNERR				WM_USER+901		//本地连接失败
#define MSG_LOCAL_SESSION_CONNERR			WM_USER+902		//本地连接失败
#define MSG_LOCAL_SESSION_CAPERR			WM_USER+903		//本地连接失败
#define MSG_LOCAL_FTPClIP_CONNERR			WM_USER+904		//本地FtpClip连接失败

#define MSG_CENTER_CONN_CONNERR				WM_USER+1001	//交互服务器连接失败
#define MSG_CENTER_CONN_AUTHERR				WM_USER+1002	//交互服务器认证失败
#define MSG_CENTER_CONN_AUTHOK				WM_USER+1003	//交互服务器认证成功
#define MSG_CENTER_CONN_CONN				WM_USER+1004	//交互服务器连接ID 返回
#define MSG_CENTER_CONN_CONNREQ				WM_USER+1005	//交互服务器连接ID 被控
#define MSG_CENTER_CONN_CONNRSP				WM_USER+1006	//交互服务器连接ID 主控

#define MSG_CENTER_CONN_FILECONN			WM_USER+1007	//交互服务器文件连接ID请求
#define MSG_CENTER_CONN_FILECONNREQ			WM_USER+1008	//交互服务器文件连接ID请求

#define MSG_CENTER_CONN_CMDCONN				WM_USER+1009	//交互服务器CMD连接ID请求

#define MSG_CENTER_CONN_CONNREQ_ERROR		WM_USER+1012	//交互服务器连接ID错误消息


#define MSG_TRANSIT_CONN_CONNERR			WM_USER+1111	//中转服务器连接失败
#define MSG_TRANSIT_CONN_AUTHERR			WM_USER+1112	//中转服务器认证失败
#define MSG_TRANSIT_CONN_AUTHOK				WM_USER+1113	//中转服务器认证成功
#define MSG_TRANSIT_FILECONN_CONNERR		WM_USER+1114	//中转文件服务器连接失败
#define MSG_TRANSIT_FILECONN_AUTHERR		WM_USER+1115	//中转文件服务器认证失败
#define MSG_TRANSIT_FILECONN_AUTHOK			WM_USER+1116	//中转文件服务器认证成功
#define MSG_TRANSIT_CMDCONN_CONNERR			WM_USER+1117	//中转CMD服务器连接失败
#define MSG_TRANSIT_CMDCONN_AUTHERR			WM_USER+1118	//中转CMD服务器认证失败
#define MSG_TRANSIT_CMDCONN_AUTHOK			WM_USER+1119	//中转CMD服务器认证成功

#define MSG_CLIENT_CONN_CONNERR				WM_USER+1221	//控制端连接失败
#define MSG_CLIENT_CONN_AUTHERR				WM_USER+1222	//控制端认证失败
#define MSG_CLIENT_CONN_AUTHOK				WM_USER+1223	//控制端认证失败
#define MSG_CLIENT_CONN_AUTH				WM_USER+1224	//控制端认证发送密码
#define MSG_CLIENT_FILECONN_CONNERR			WM_USER+1225	//文件控制端文件连接失败
#define MSG_CLIENT_FILECONN_AUTHERR			WM_USER+1226	//文件控制端文件认证失败
#define MSG_CLIENT_FILECONN_AUTHOK			WM_USER+1227	//文件控制端文件认证成功
#define MSG_CLIENT_FILECONN_AUTH			WM_USER+1228	//文件控制端认证发送密码
#define MSG_CLIENT_CMDCONN_CONNERR			WM_USER+1229	//CMD控制端连接失败
#define MSG_CLIENT_CMDCONN_AUTHERR			WM_USER+1230	//CMD控制端认证失败
#define MSG_CLIENT_CMDCONN_AUTHOK			WM_USER+1231	//CMD控制端认证成功
#define MSG_CLIENT_CMDCONN_AUTH				WM_USER+1232	//CMD控制端认证发送密码

#define MSG_HOST_CONN_CONNERR				WM_USER+1331	//被控端连接失败
#define MSG_HOST_CONN_AUTHERR				WM_USER+1332	//被控端认证失败
#define MSG_HOST_CONN_AUTHOK				WM_USER+1333	//被控端认证失败
#define MSG_HOST_FILECONN_CONNERR			WM_USER+1334	//文件被控端连接失败
#define MSG_HOST_FILECONN_AUTHERR			WM_USER+1335	//文件被控端认证失败
#define MSG_HOST_FILECONN_AUTHOK			WM_USER+1336	//文件被控端认证失败
#define MSG_HOST_CMDCONN_CONNERR			WM_USER+1337	//cmd被控端连接失败
#define MSG_HOST_CMDCONN_AUTHERR			WM_USER+1338	//cmd被控端认证失败
#define MSG_HOST_CMDCONN_AUTHOK				WM_USER+1339	//cmd被控端认证失败
#define MSG_HOST_CLIENTCONN_BREAK			WM_USER+1340	//控制端连接断开	

#define MSG_FILE_CONN_STATUS				WM_USER+1441	//文件系统操作状态
#define MSG_FILETRANS_STATUS				WM_USER+1442	//文件传输状态
#define MSG_FILETRANS_PROGRESS				WM_USER+1443	//文件传输进度
#define MSG_FILE_CONN_DISCONN				WM_USER+1444	//文件传输连接断开
#define MSG_FILE_CONN_CONNOK				WM_USER+1445	//文件传输建立连接

#define MSG_FILETRANS_STATUS_FINISH			WM_USER+1446	//文件传输状态

#define MSG_FILETRANS_UPLOAD_START			WM_USER+1448	//文件传输 开始上传
#define MSG_FILETRANS_UPLOADOK				WM_USER+1449	//文件传输 上传成功
#define MSG_FILETRANS_UPLOADERR				WM_USER+1450	//文件传输 上传失败

#define MSG_FILETRANS_DOWNLOAD_START		WM_USER+1451	//文件传输 开始下载
#define MSG_FILETRANS_DOWNLOADOK			WM_USER+1452	//文件传输 下载成功
#define MSG_FILETRANS_DOWNLOADERR			WM_USER+1453	//文件传输 下载失败

#define MSG_FILETRANS_DELETEOK				WM_USER+1454	//文件传输 删除成功
#define MSG_FILETRANS_DELETEERR				WM_USER+1455	//文件传输 删除失败

#define MSG_FILETRANS_CREATEDIR_OK			WM_USER+1456	//文件传输 创建文件夹成功
#define MSG_FILETRANS_CREATEDIR_ERR			WM_USER+1457	//文件传输 创建文件夹失败

#define MSG_FILETRANS_RENAME_OK				WM_USER+1458	//文件传输 重命名成功
#define MSG_FILETRANS_RENAME_ERR			WM_USER+1459	//文件传输 重命名失败


#define MSG_FILETRANS_SIZELIMIT				WM_USER+1460	//文件传输 超出限制大小
#define MSG_FILETRANS_CLOSE					WM_USER+1461	//文件传输 主动关闭

#define MSG_FILETRANS_QUEUEERR				WM_USER+1462	//文件传输 队列异常
#define MSG_FILETRANS_CANCEL				WM_USER+1463	//文件传输 取消操作
#define MSG_FILETRANS_START					WM_USER+1464	//文件传输 开始传输

#define MSG_FILETRANS_SAMEFILE_UPLOAD		WM_USER+1465	//文件传输 文件相同时提示
#define MSG_FILETRANS_SAMEFILE_DOWNLOAD		WM_USER+1466	//文件传输 文件相同时提示

#define MSG_CMDDLG_CLOSE					WM_USER+1480	//关闭CMD窗口

#define	MSG_REG_PHONE_OK					WM_USER+1561	//发送注册验证码OK
#define	MSG_REG_PHONE_ERROR					WM_USER+1562	//发送注册验证码失败
#define MSG_REG_PHONE_TIMER					WM_USER+1563	//发送注册码倒计时 定时器
#define	MSG_REG_USER_OK						WM_USER+1565	//手机注册成功
#define	MSG_REG_USER_ERROR					WM_USER+1566	//手机注册失败
#define	MSG_LOGIN_USER_RESULT				WM_USER+1567	//手机登录成功
#define	MSG_LOGIN_UPDATE_DLG				WM_USER+1569	//手机登录成功通知更新界面
#define MSG_EDIT_GROUP_RESULT				WM_USER+1570	//操作分组返回结果
#define MSG_EDIT_DEVICE_RESULT				WM_USER+1571	//操作分组返回结果
#define MSG_GROUP_UPDATE_DLG				WM_USER+1572	//分组更新结果
#define MSG_CLIPFILE_UPDATE					WM_USER+1573	//剪切板文件更新
#define MSG_WALLPAPER						WM_USER+1574	//墙纸消息

#define MSG_CLIPBOARD_TYPE					WM_USER+1575	//剪切板类型同步
#define MSG_CLIPBOARD_TYPEREQUEST			WM_USER+1576	//剪切板类型同步
#define MSG_CLIPBOARD_TYPEREQUESTDATA		WM_USER+1577	//剪切板类型同步

#define MSG_NICKNAME_UPDATE					WM_USER+1581	//昵称更新
#define MSG_DEVICE_UPDATE					WM_USER+1582	//机器上下线更新
#define MSG_ACTION_RESULT					WM_USER+1583	//远程操作结果回复


#define	MSG_CHANGE_PASSWORD_OK				WM_USER+1590	//手机修改密码成功
#define	MSG_CHANGE_PASSWORD_ERROR			WM_USER+1591	//手机修改密码失败
#define MSG_SHOW_FPS						WM_USER+1600	//显示帧率
#define MSG_FRAMESIZE_CHANGED				WM_USER+1601	//帧大小改变

#define MSG_CHAT_MSG						WM_USER+1610	//聊天消息
#define MSG_SETTING_MSG						WM_USER+1612	//设置消息
#define MSG_INPUTBLOCK_RESULT_MSG			WM_USER+1613	//禁止远程输入结果消息

#define MSG_CMDINFO_MSG						WM_USER+1620	//CMD 输出消息

#define TIMER_RECONN_CENTER					1001			//重连交互服务器定时器
#define TIMER_HEARTBEAT						1002			//心跳定时器
#define TIMER_AUTO_HIDE						1003			//自动隐藏提示框
#define TIMER_AUTO_SHOWEDIT					1004			//自动隐藏提示框
#define TIMER_DELAY_DELETE_ITEM				1005			//自动隐藏提示框
#define TIMER_UPDATE_PASSWORD				1006			//定时更新密码
#define TIMER_DELAY_DELETE_LOCALPATH		1007			//自动隐藏提示框
#define TIMER_DELAY_DELETE_REMOTEPATH		1008			//自动隐藏提示框
#define TIMER_CHECK_UPDATE					1009			//定时检测版本号
#define TIMER_DELAY_SETFOCUS				1010			//延时设置输入焦点
#define TIMER_TRAY_CHECK					1011			//检查托盘
#define TIMER_SHOW_SPEED					1012			//定时更新文件传输速度
#define TIMER_DELAY_LAUNCH_SERVICE			1013			//延时启动服务

//ui自定义消息
#define MSG_FILEITEM_DBCLICK				WM_USER+3001	//文件列表双击消息
#define MSG_DROPFILES						WM_USER+3002	//文件拖拽消息
#define MSG_PASTE_FILES						WM_USER+3003	//文件剪切版粘贴消息
#define MSG_PASTE_REMOTEFILES				WM_USER+3004	//文件剪切版粘贴消息

#define MSG_CONN_MODE_CHANGED				WM_USER+3010	//文件列表双击消息
#define MSG_CONN_RECT_CHANGED				WM_USER+3011	//文件列表双击消息


#define MSG_SHOW_TIPTEXT					WM_USER+3013	//文件列表双击消息

#define MSG_TRAY_MENU						WM_USER+3014	//托盘消息
#define MSG_TRAY_MENU_CLOSE					WM_USER+3015	//退出消息
#define MSG_SHOW_MAINWINDOW					WM_USER+3016	//显示主窗口消息

#define MSG_CHOOSEDEVICE					WM_USER+3017	//选择设备ID消息

#define MSG_CONNMNG_CLOSE_ALL				WM_USER+3021	//文件列表双击消息
#define MSG_CONNMNG_CLOSE_CONN				WM_USER+3022	//文件列表双击消息

#define MSG_SEND_CAD						WM_USER+3100	//发送cad命令
#define MSG_SEND_LOGOFF						WM_USER+3101	//发送注销命令
#define MSG_SEND_LOCK						WM_USER+3102	//发送立即锁定命令
#define MSG_SEND_REBOOT						WM_USER+3103	//发送重启命令
#define MSG_SEND_SESSION_END_LOCK			WM_USER+3104	//发送立即锁定命令
#define MSG_ACTIONMENU_KILLFOCUS			WM_USER+3105	//发送立即锁定命令
#define MSG_VIEWMENU_KILLFOCUS				WM_USER+3106	//发送立即锁定命令
#define MSG_WND_KILLFOCUS					WM_USER+3107	//发送失去焦点消息
#define MSG_PLAY_VOICE						WM_USER+3108	//发送是否开启声音
#define MSG_SEND_SHUTDOWN					WM_USER+3109	//发送关机命令
#define MSG_SEND_CHANGEMARK					WM_USER+3110	//发送修改备注命令
#define MSG_SEND_UPDATESCREENLIST			WM_USER+3111	//发送被控屏幕数量变化命令
#define MSG_SEND_REMOTEINPUTBLOCK			WM_USER+3112	//发送被控禁止输入命令

#define MSG_APP_HAS_NEW_VERSION				WM_USER+3201	//有新版本升级

#define MSG_FILETRAN_CLICK					WM_USER+3203	//文件传输点击事件
#define MSG_FULLSCREEN_CLICK				WM_USER+3204	//全屏点击事件
#define MSG_MACTHSCREEN_CLICK				WM_USER+3205	//匹配最佳分辨率
#define MSG_STRETCHMODE_CLICK				WM_USER+3206	//拉伸模式
#define MSG_ZOOMMODE_CLICK					WM_USER+3207	//缩放模式
#define MSG_SCREEN_MIN						WM_USER+3208	//最小化

#define MSG_FILETRANS_ALREADY_EXIST			WM_USER+3308
#define MSG_SHOW_TRANSTYPE					WM_USER+3309
#define MSG_HOST_P2PCONN_CONNERR			WM_USER+3310	//被控端连接失败

#define MSG_FTP_GET_START					WM_USER+3311
#define MSG_FTP_GET_END						WM_USER+3312
#define MSG_FTP_SET_FILEINFO				WM_USER+3313

#define MSG_CONNECT_TIP					WM_USER+3314	//主控端连接后，显示服务器的提示消息

#define	MSG_PROXY_CHECKRESULT				WM_USER+3400	//检测proxy结果消息
#define	MSG_IMAGE_QUALITY_UPDATED			WM_USER+3401	//清晰度变化消息

#define	MSG_DETECTVOICE						WM_USER+3402	//检测声音消息
#define	MSG_HOST_FILE_OPER_TIP				WM_USER+3403	//被控端被主控端文件传输时 提示主控端的文件传输操作
#define MSG_SHOW_FILETRANSDLG				WM_USER+3404	//显示文件传输窗口
