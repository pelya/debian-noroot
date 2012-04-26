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

Currently it does not fill h_aliases list, only h_name.
It's licensed the same way as C-Ares lib is, if anyone cares about that.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
#include "ares.h"

/* #define dbg(...) */

#define dbg(...) printf(__VA_ARGS__)


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
		ares_library_init(ARES_LIB_INIT_ALL);
		aresInitDone = 1;
		he.h_name = f_name;
		he.h_aliases = &f_empty;
		he.h_addrtype = 0;
		he.h_length = 0;
		he.h_addr_list = f_addrlist;
	}

	ares_init(channel);
	ares_set_servers_csv(*channel, "8.8.8.8,8.8.4.4");
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

extern struct hostent *gethostbyname (__const char *__name)
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

extern struct hostent *gethostbyaddr (__const void *__addr, __socklen_t __len, int __af)
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

extern struct hostent *gethostbyname2 (__const char *__name, int __af)
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

extern int gethostbyaddr_r (__const void *__restrict __addr, __socklen_t __len,
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

extern int gethostbyname_r (__const char *__restrict __name,
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

extern int gethostbyname2_r (__const char *__restrict __name, int __af,
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

extern void freeaddrinfo (struct addrinfo *__ai)
{
	struct addrinfo *next, *curr;
	for( next = __ai; next; )
	{
		curr = next;
		next = next->ai_next;
		free(curr);
	}
}

static void getaddrinfo_callback(void *arg, int status, int timeouts, struct hostent *host)
{
	char **p;
	int i;
	struct addrinfo ** out = (struct addrinfo **) arg;
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
		strncpy(data->ai_canonname, host->h_name, HLEN);
		data->ai_canonname[HLEN-1] = 0;
		data->ai_family = host->h_addrtype;
		data->ai_socktype = 0;
		data->ai_protocol = host->h_addrtype;
		data->ai_flags = 0;
		data->ai_addrlen = host->h_length;
		memcpy(data->ai_addr, host->h_addr_list[i], host->h_length);
	}
}

extern int getaddrinfo (__const char *__restrict __name,
			__const char *__restrict __service,
			__const struct addrinfo *__restrict __req,
			struct addrinfo **__restrict __pai)
{
	/* TODO: __service is ignored */
	ares_channel channel;
	int nfds, c;
	fd_set read_fds, write_fds;
	struct timeval *tvp, tv;

	dbg("%s\n", __FUNCTION__);
	aresInit(&channel);
	ares_gethostbyname(channel, __name, __req ? __req->ai_family : AF_INET, getaddrinfo_callback, __pai);
	
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
	
	if (! (*__pai) )
		return EAI_FAIL;
	(*__pai)->ai_socktype = __req ? __req->ai_socktype : 0;
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

	if(out->host)
	{
		strncpy(out->host, node, out->hostlen);
		out->host[out->hostlen-1] = 0;
	}
	if(out->serv)
	{
		strncpy(out->serv, service, out->servlen);
		out->serv[out->servlen-1] = 0;
	}
}

extern int getnameinfo (__const struct sockaddr *__restrict __sa,
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

	dbg("%s\n", __FUNCTION__);
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
