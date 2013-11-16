/*
Debian/Ubuntu inside fakechroot on Android fails miserably when trying to resolve DNS names.
So this library overrides standard system calls with calls that work. The calls overridden are:
gethostbyname
gethostbyname2
gethostbyaddr
gethostbyname_r
gethostbyname2_r
gethostbyaddr_r
getaddrinfo
freeaddrinfo
getnameinfo
getservbyport

Currently it does not fill h_aliases list, only h_name.
It's licensed the same way as C-Ares lib is, if anyone cares about that.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
#include "ares.h"
#include "ares_setup.h"
#include "ares_private.h"
#include "ares_platform.h"

#define dbg(...)
/*
#define dbg(...) fprintf(stderr, __VA_ARGS__)
*/

/* Declarations */

#define FAKEDNS_EXTERN  __attribute__((__visibility__("default")))

FAKEDNS_EXTERN struct hostent *gethostbyname (__const char *__name);

FAKEDNS_EXTERN struct hostent *gethostbyaddr (__const void *__addr, __socklen_t __len, int __af);

FAKEDNS_EXTERN struct hostent *gethostbyname2 (__const char *__name, int __af);

FAKEDNS_EXTERN int gethostbyaddr_r (__const void *__restrict __addr, __socklen_t __len,
			    int __af,
			    struct hostent *__restrict __result_buf,
			    char *__restrict __buf, size_t __buflen,
			    struct hostent **__restrict __result,
			    int *__restrict __h_errnop);

FAKEDNS_EXTERN int gethostbyname_r (__const char *__restrict __name,
			    struct hostent *__restrict __result_buf,
			    char *__restrict __buf, size_t __buflen,
			    struct hostent **__restrict __result,
			    int *__restrict __h_errnop);

FAKEDNS_EXTERN int gethostbyname2_r (__const char *__restrict __name, int __af,
			     struct hostent *__restrict __result_buf,
			     char *__restrict __buf, size_t __buflen,
			     struct hostent **__restrict __result,
			     int *__restrict __h_errnop);


FAKEDNS_EXTERN void freeaddrinfo (struct addrinfo *__ai);

FAKEDNS_EXTERN int getaddrinfo (__const char *__restrict __name,
			__const char *__restrict __service,
			__const struct addrinfo *__restrict __req,
			struct addrinfo **__restrict __pai);

FAKEDNS_EXTERN int getnameinfo (__const struct sockaddr *__restrict __sa,
			socklen_t __salen, char *__restrict __host,
			socklen_t __hostlen, char *__restrict __serv,
			socklen_t __servlen, unsigned int __flags);

FAKEDNS_EXTERN struct servent *getservbyport(int port, const char *proto);

/* Implementation */


#if 0
struct hostent
{
  char *h_name;			/* Official name of host.  */
  char **h_aliases;		/* Alias list.  */
  int h_addrtype;		/* Host address type.  */
  int h_length;			/* Length of address.  */
  char **h_addr_list;		/* List of addresses from name server.  */
};
#endif

#define HLEN 1024
#define ALEN 10

static char f_name[HLEN];
static char f_names[ALEN][HLEN];
static char * f_aliases[ALEN];
static struct sockaddr f_addr[ALEN];
static char * f_addrlist[ALEN];
static struct sockaddr f_addrbuf[ALEN];
static char * f_empty = NULL;
static struct hostent he;

static int aresInitDone = 0;
static aresInit(ares_channel * channel)
{
	if(!aresInitDone)
	{
		dbg("%s: ares_library_init\n", __FUNCTION__);
		ares_library_init(ARES_LIB_INIT_ALL);
		aresInitDone = 1;
		he.h_name = f_name;
		he.h_aliases = &f_empty;
		he.h_addrtype = 0;
		he.h_length = 0;
		he.h_addr_list = f_addrlist;
	}

	dbg("%s: ares_init\n", __FUNCTION__);
	ares_init(channel);
	dbg("%s: ares_set_servers_csv\n", __FUNCTION__);
	ares_set_servers_csv(*channel, "8.8.8.8,8.8.4.4");
	dbg("%s: done\n", __FUNCTION__);
}

static struct sockaddr * initHostent(struct hostent *__restrict __result_buf, char *__restrict __buf, size_t __buflen)
{
	if( __buflen < HLEN + sizeof(char*) * ALEN + sizeof(struct sockaddr) * ALEN )
		return NULL;
	__result_buf->h_name = __buf;
	__result_buf->h_aliases = &f_empty;
	__result_buf->h_addr_list = (char **)(__buf + HLEN);
	
	return (struct sockaddr *)(__buf + HLEN + sizeof(char*) * ALEN);
}

typedef struct { struct hostent * host; struct sockaddr * addrbuf; } gethostbyname_callback_arg;

static void gethostbyname_callback(void *arg, int status, int timeouts, struct hostent *host)
{
	char **p;
	int i;
	gethostbyname_callback_arg * harg = (gethostbyname_callback_arg *) arg;
	struct hostent * out = harg->host;
	struct sockaddr * addrbuf = harg->addrbuf;

	(void)timeouts;
	if (status != ARES_SUCCESS)
	{
		out->h_name[0] = 0;
		out->h_aliases[0] = NULL;
		out->h_addrtype = AF_INET;
		out->h_length = 0;
		out->h_addr_list[0] = 0;
		return;
	}

	strncpy(out->h_name, host->h_name, HLEN);
	out->h_name[HLEN-1] = 0;
	out->h_aliases = &f_empty; // Ignore aliases for now
	out->h_addrtype = host->h_addrtype;
	out->h_length = host->h_length;
	for (i = 0; i < ALEN-1 && host->h_addr_list[i]; i++)
	{
		out->h_addr_list[i] = (char *)(addrbuf + i);
		memcpy(out->h_addr_list[i], host->h_addr_list[i], host->h_length);
	}
	out->h_addr_list[i] = NULL;

	/*
	for (i = 0; i < ALEN-1 && host->h_aliases[i] ; i++)
	{
		out->h_aliases[i] = h_aliases[i];
		strncpy(out->h_aliases[i], host->h_aliases[i], HLEN);
		out->h_aliases[i][HLEN-1] = 0;
	}
	out->h_aliases[i] = NULL;
	*/
}

struct hostent *gethostbyname (__const char *__name)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	gethostbyname_callback_arg harg = { &he, f_addrbuf };

	dbg("%s %s\n", __FUNCTION__, __name);
	aresInit(&channel);
	ares_gethostbyname(channel, __name, AF_INET, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);
	
	return he.h_length ? & he : NULL;
}

struct hostent *gethostbyaddr (__const void *__addr, __socklen_t __len, int __af)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	gethostbyname_callback_arg harg = { &he, f_addrbuf };

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyaddr(channel, __addr, __len, __af, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);
	
	return he.h_length ? & he : NULL;
}

struct hostent *gethostbyname2 (__const char *__name, int __af)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	gethostbyname_callback_arg harg = { &he, f_addrbuf };

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyname(channel, __name, __af, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);
	
	return he.h_length ? & he : NULL;
}

int gethostbyaddr_r (__const void *__restrict __addr, __socklen_t __len,
			    int __af,
			    struct hostent *__restrict __result_buf,
			    char *__restrict __buf, size_t __buflen,
			    struct hostent **__restrict __result,
			    int *__restrict __h_errnop)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	struct sockaddr * addrbuf = initHostent(__result_buf, __buf, __buflen);
	gethostbyname_callback_arg harg = { __result_buf, addrbuf };
	if( !addrbuf )
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = ERANGE;
		return -1;
	}

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyaddr(channel, __addr, __len, __af, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);

	if (!he.h_length)
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = HOST_NOT_FOUND;
	}
	
	if(__result)
		*__result = __result_buf;
	if(__h_errnop)
		*__h_errnop = 0;

	return 0;
}

int gethostbyname_r (__const char *__restrict __name,
			    struct hostent *__restrict __result_buf,
			    char *__restrict __buf, size_t __buflen,
			    struct hostent **__restrict __result,
			    int *__restrict __h_errnop)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	struct sockaddr * addrbuf = initHostent(__result_buf, __buf, __buflen);
	gethostbyname_callback_arg harg = { __result_buf, addrbuf };
	if( !addrbuf )
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = ERANGE;
		return -1;
	}

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyname(channel, __name, AF_INET, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);

	if (!he.h_length)
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = HOST_NOT_FOUND;
	}
	
	if(__result)
		*__result = __result_buf;
	if(__h_errnop)
		*__h_errnop = 0;

	return 0;
}

int gethostbyname2_r (__const char *__restrict __name, int __af,
			     struct hostent *__restrict __result_buf,
			     char *__restrict __buf, size_t __buflen,
			     struct hostent **__restrict __result,
			     int *__restrict __h_errnop)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	struct sockaddr * addrbuf = initHostent(__result_buf, __buf, __buflen);
	gethostbyname_callback_arg harg = { __result_buf, addrbuf };
	if( !addrbuf )
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = ERANGE;
		return -1;
	}

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyname(channel, __name, __af, gethostbyname_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	ares_destroy(channel);

	if (!he.h_length)
	{
		if(__result)
			*__result = NULL;
		if(__h_errnop)
			*__h_errnop = HOST_NOT_FOUND;
	}
	
	if(__result)
		*__result = __result_buf;
	if(__h_errnop)
		*__h_errnop = 0;

	return 0;
}

#if 0
struct addrinfo
{
  int ai_flags;			/* Input flags.  */
  int ai_family;		/* Protocol family for socket.  */
  int ai_socktype;		/* Socket type.  */
  int ai_protocol;		/* Protocol for socket.  */
  socklen_t ai_addrlen;		/* Length of socket address.  */
  struct sockaddr *ai_addr;	/* Socket address for socket.  */
  char *ai_canonname;		/* Canonical name for service location.  */
  struct addrinfo *ai_next;	/* Pointer to next in list.  */
};
#endif

typedef struct 
{
	struct addrinfo ai;
	struct sockaddr addr;
	char name[HLEN];
}
addinfo_data;

static struct addrinfo * allocaddrinfo()
{
	addinfo_data *data = (addinfo_data *)malloc(sizeof(addinfo_data));
	memset(data, 0, sizeof(addinfo_data));
	data->ai.ai_addr = &data->addr;
	data->ai.ai_canonname = data->name;
	return &(data->ai);
}

void freeaddrinfo (struct addrinfo *__ai)
{
	struct addrinfo *next, *curr;
	for( next = __ai; next; )
	{
		curr = next;
		next = next->ai_next;
		free(curr);
	}
}

typedef struct {
	struct addrinfo ** out;
	in_port_t port;
	int socktype;
}
getaddrinfo_callback_param;

static void getaddrinfo_callback(void *arg, int status, int timeouts, struct hostent *host)
{
	char **p;
	int i;
	getaddrinfo_callback_param * harg = (getaddrinfo_callback_param *) arg;
	struct addrinfo ** out = harg->out;
	struct addrinfo * data;

	(void)timeouts;
	if (status != ARES_SUCCESS)
	{
		*out = NULL;
		return;
	}

	for (i = 0; host->h_addr_list[i]; i++)
	{
		if( i == 0 )
		{
			data = allocaddrinfo();
			*out = data;
		}
		else
		{
			data->ai_next = allocaddrinfo();
			data = data->ai_next;
		}
		dbg("%s: '%s' %i AF %d addrlen %d\n", __FUNCTION__, host->h_name, i, host->h_addrtype, host->h_length);
		strncpy(data->ai_canonname, host->h_name, HLEN);
		data->ai_canonname[HLEN-1] = 0;
		data->ai_family = host->h_addrtype;
		data->ai_socktype = harg->socktype;
		data->ai_protocol = 0;
		data->ai_flags = 0;
		data->ai_addrlen = host->h_length + sizeof(sa_family_t);
		if( host->h_addrtype == AF_INET && host->h_length == sizeof(struct in_addr) )
		{
			struct sockaddr_in * addr = (struct sockaddr_in *)data->ai_addr;
			addr->sin_family = AF_INET;
			addr->sin_port = harg->port;
			memcpy(&(addr->sin_addr), host->h_addr_list[i], host->h_length);
			data->ai_addrlen = sizeof(struct sockaddr_in);
		}
		else if( host->h_addrtype == AF_INET6 && host->h_length == sizeof(struct in6_addr) )
		{
			struct sockaddr_in6 * addr = (struct sockaddr_in6 *)data->ai_addr;
			addr->sin6_family = AF_INET6;
			addr->sin6_port = harg->port;
			memcpy(&(addr->sin6_addr), host->h_addr_list[i], host->h_length);
			data->ai_addrlen = sizeof(struct sockaddr_in6);
		}
		else
			memcpy(data->ai_addr+sizeof(sa_family_t), host->h_addr_list[i], host->h_length);
	}
}

int getaddrinfo (__const char *__restrict __name,
			__const char *__restrict __service,
			__const struct addrinfo *__restrict __req,
			struct addrinfo **__restrict __pai)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	struct addrinfo * data;
	getaddrinfo_callback_param harg = { __pai, __service ? htons(atoi(__service)) : 0, __req ? __req->ai_socktype : 0 };
	struct in_addr ip4;
	struct in6_addr ip6;

	dbg("%s: '%s':'%s' AF %d\n", __FUNCTION__, __name, __service, __req ? __req->ai_family : -1);

	if(__service && harg.port == 0)
	{
		struct servent * serv = getservbyname(__service, NULL);
		if(serv)
		{
			dbg("%s: getservbyname: '%s':%d:'%s'\n", __FUNCTION__, serv->s_name, (int)ntohs(serv->s_port), serv->s_proto);
			harg.port = serv->s_port;
			if( harg.socktype == 0 )
			{
				if( strcmp( serv->s_proto, "tcp" ) == 0 )
					harg.socktype = SOCK_STREAM;
				if( strcmp( serv->s_proto, "udp" ) == 0 )
					harg.socktype = SOCK_DGRAM;
			}
		}
	}

	if (inet_pton(AF_INET, __name, &ip4) == 1)
	{
		struct addrinfo * data = allocaddrinfo();
		struct sockaddr_in * addr = (struct sockaddr_in *)data->ai_addr;
		*__pai = data;
		strncpy(data->ai_canonname, __name, HLEN);
		data->ai_canonname[HLEN-1] = 0;
		data->ai_family = AF_INET;
		data->ai_socktype = harg.socktype;
		data->ai_protocol = 0;
		data->ai_flags = 0;
		addr->sin_family = AF_INET;
		addr->sin_port = harg.port;
		memcpy(&(addr->sin_addr), &ip4, sizeof(ip4));
		data->ai_addrlen = sizeof(struct sockaddr_in);
		return 0;
	}

	if (inet_pton(AF_INET6, __name, &ip6) == 1)
	{
		struct addrinfo * data = allocaddrinfo();
		struct sockaddr_in6 * addr = (struct sockaddr_in6 *)data->ai_addr;
		*__pai = data;
		strncpy(data->ai_canonname, __name, HLEN);
		data->ai_canonname[HLEN-1] = 0;
		data->ai_family = AF_INET6;
		data->ai_socktype = harg.socktype;
		data->ai_protocol = 0;
		data->ai_flags = 0;
		addr->sin6_family = AF_INET6;
		addr->sin6_port = harg.port;
		memcpy(&(addr->sin6_addr), &ip6, sizeof(ip6));
		data->ai_addrlen = sizeof(struct sockaddr_in6);
		return 0;
	}

	dbg("%s: aresInit\n", __FUNCTION__);

	aresInit(&channel);
	dbg("%s: ares_gethostbyname\n", __FUNCTION__);
	ares_gethostbyname(channel, __name, __req ? (__req->ai_family != 0 ? __req->ai_family : AF_INET) : AF_INET, getaddrinfo_callback, &harg);
	dbg("%s: loop\n", __FUNCTION__);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}
	
	dbg("%s: ares_destroy\n", __FUNCTION__);
	ares_destroy(channel);

	dbg("%s: exit\n", __FUNCTION__);
	
	if (! (*harg.out) )
		return EAI_FAIL;
	
	return 0;
}

typedef struct {
	char * host;
	socklen_t hostlen;
	char * serv;
	socklen_t servlen;
	int ret;
}
getnameinfo_callback_arg;

static void getnameinfo_callback(void *arg, int status, int timeouts, char *node, char *service)
{
	getnameinfo_callback_arg * out = (getnameinfo_callback_arg*) arg;

	(void)timeouts;
	if (status != ARES_SUCCESS)
	{
		out->ret = EAI_FAIL;
		return;
	}
	out->ret = 0;

	dbg("%s: %s:%s\n", __FUNCTION__, node, service);

	if(out->host && node)
	{
		strncpy(out->host, node, out->hostlen);
		out->host[out->hostlen-1] = 0;
	}
	if(out->serv && service)
	{
		strncpy(out->serv, service, out->servlen);
		out->serv[out->servlen-1] = 0;
	}
}

int getnameinfo (__const struct sockaddr *__restrict __sa,
			socklen_t __salen, char *__restrict __host,
			socklen_t __hostlen, char *__restrict __serv,
			socklen_t __servlen, unsigned int __flags)
{
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;
	getnameinfo_callback_arg harg;
	int flags = 0;

	harg.host = __host;
	harg.hostlen = __hostlen;
	harg.serv = __serv;
	harg.servlen = __servlen;
	harg.ret = 0;
	if(__flags & NI_NUMERICHOST)
		flags &= ARES_NI_NUMERICHOST;
	if(__flags & NI_NUMERICSERV)
		flags &= ARES_NI_NUMERICSERV;
	if(__flags & NI_NOFQDN)
		flags &= ARES_NI_NOFQDN;
	if(__flags & NI_DGRAM)
		flags &= ARES_NI_DGRAM;
	if(__flags & NI_NAMEREQD)
		flags &= ARES_NI_NAMEREQD;

	if(__sa->sa_family == AF_INET)
		dbg("%s: AF_INET addr 0x%08X port %d\n", __FUNCTION__, ntohl(((struct sockaddr_in *)__sa)->sin_addr.s_addr), (int)ntohs(((struct sockaddr_in *)__sa)->sin_port));
	else
	if(__sa->sa_family == AF_INET6)
		dbg("%s: AF_INET6 port %d addr %04X:%04X:%04X:%04X:%04X:%04X:%04X:%04X\n", __FUNCTION__, (int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_port),
			(int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[0]), (int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[1]),
			(int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[2]), (int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[3]),
			(int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[4]), (int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[5]),
			(int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[6]), (int)ntohs(((struct sockaddr_in6 *)__sa)->sin6_addr.s6_addr16[7]));
	else
		dbg("%s: AF %d\n", __FUNCTION__, __sa->sa_family);
	aresInit(&channel);
	ares_getnameinfo(channel, __sa, __salen, flags, getnameinfo_callback, &harg);
	
	for (;;)
	{
		FD_ZERO(&read_fds);
		FD_ZERO(&write_fds);
		nfds = ares_fds(channel, &read_fds, &write_fds);
		if (nfds == 0)
			break;
		tvp = ares_timeout(channel, NULL, &tv);
		select(nfds, &read_fds, &write_fds, NULL, tvp);
		ares_process(channel, &read_fds, &write_fds);
	}

	ares_destroy(channel);

	return harg.ret;
}

struct servent *getservbyport(int port, const char *proto)
{
	return ares_getservbyport(port, proto);
}
