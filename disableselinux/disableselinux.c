#include <errno.h>

extern int audit_open (void);
extern int is_selinux_enabled (void);


int audit_open (void)
{
	errno == EPROTONOSUPPORT;
	return -1;
}

int is_selinux_enabled (void)
{
	return 0;
}
