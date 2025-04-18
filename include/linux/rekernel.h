// Rekernel Header
#ifndef REKERNEL_H
#define REKERNEL_H
#include <linux/netlink.h>
#include <linux/freezer.h>
#include <net/sock.h>
#include <linux/proc_fs.h>
#include <linux/sched.h>
#define NETLINK_REKERNEL_MAX     		26
#define NETLINK_REKERNEL_MIN     		22
#define REKERNEL_USER_PORT        			    100
#define REKERNEL_PACKET_SIZE 				    128
#define REKERNEL_MIN_USERAPP_UID (10000)
#define REKERNEL_MAX_SYSTEM_UID  (2000)
#define REKERNEL_RESERVE_ORDER  17
#define REKERNEL_WARN_AHEAD_SPACE  (1 << REKERNEL_RESERVE_ORDER)
static struct sock *rekernel_netlink;
static int rekernel_netlink_unit;
#endif