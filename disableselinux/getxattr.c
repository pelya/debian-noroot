#include <errno.h>
#include <sys/types.h>

extern ssize_t getxattr(const char *path, const char *name, void *value, size_t size);
ssize_t getxattr(const char *path, const char *name, void *value, size_t size)
{
	errno = ENOTSUP;
	return -1;
}

extern ssize_t lgetxattr(const char *path, const char *name, void *value, size_t size);
ssize_t lgetxattr(const char *path, const char *name, void *value, size_t size)
{
	errno = ENOTSUP;
	return -1;
}

extern ssize_t fgetxattr(int fd, const char *name, void *value, size_t size);
ssize_t fgetxattr(int fd, const char *name, void *value, size_t size)
{
	errno = ENOTSUP;
	return -1;
}

extern ssize_t listxattr(const char *path, char *list, size_t size);
ssize_t listxattr(const char *path, char *list, size_t size)
{
	errno = ENOTSUP;
	return -1;
	//return 0;
}

extern ssize_t llistxattr(const char *path, char *list, size_t size);
ssize_t llistxattr(const char *path, char *list, size_t size)
{
	errno = ENOTSUP;
	return -1;
}

extern ssize_t flistxattr(int fd, char *list, size_t size);
ssize_t flistxattr(int fd, char *list, size_t size)
{
	errno = ENOTSUP;
	return -1;
}

extern int removexattr(const char *path, const char *name);
int removexattr(const char *path, const char *name)
{
	errno = ENOTSUP;
	return -1;
}

extern int lremovexattr(const char *path, const char *name);
int lremovexattr(const char *path, const char *name)
{
	errno = ENOTSUP;
	return -1;
}

extern int fremovexattr(int fd, const char *name);
int fremovexattr(int fd, const char *name)
{
	errno = ENOTSUP;
	return -1;
}

extern int setxattr(const char *path, const char *name, const void *value, size_t size, int flags);
int setxattr(const char *path, const char *name, const void *value, size_t size, int flags)
{
	errno = ENOTSUP;
	return -1;
}

extern int lsetxattr(const char *path, const char *name, const void *value, size_t size, int flags);
int lsetxattr(const char *path, const char *name, const void *value, size_t size, int flags)
{
	errno = ENOTSUP;
	return -1;
}

extern int fsetxattr(int fd, const char *name, const void *value, size_t size, int flags);
int fsetxattr(int fd, const char *name, const void *value, size_t size, int flags)
{
	errno = ENOTSUP;
	return -1;
}
