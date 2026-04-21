#include <sys/stat.h>

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
