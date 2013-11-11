#include <errno.h>

extern int audit_open (void);

int audit_open (void)
{
	errno == EPROTONOSUPPORT;
	return -1;
}
