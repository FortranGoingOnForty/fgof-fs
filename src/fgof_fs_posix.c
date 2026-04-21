#include <sys/stat.h>
#include <unistd.h>

int fgof_fs_stat_mode(const char *pathname) {
    struct stat st;
    if (stat(pathname, &st) != 0) {
        return -1;
    }
    return (int)st.st_mode;
}

int fgof_fs_lstat_mode(const char *pathname) {
    struct stat st;
    if (lstat(pathname, &st) != 0) {
        return -1;
    }
    return (int)st.st_mode;
}

long long fgof_fs_stat_size(const char *pathname) {
    struct stat st;
    if (stat(pathname, &st) != 0) {
        return -1;
    }
    return (long long)st.st_size;
}

long long fgof_fs_lstat_size(const char *pathname) {
    struct stat st;
    if (lstat(pathname, &st) != 0) {
        return -1;
    }
    return (long long)st.st_size;
}

int fgof_fs_getcwd(char *buffer, int buffer_len) {
    if (getcwd(buffer, (size_t)buffer_len) == NULL) {
        return 0;
    }
    return 1;
}
