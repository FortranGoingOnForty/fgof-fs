#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
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

int fgof_fs_scandir_count(const char *pathname) {
    DIR *dir;
    struct dirent *entry;
    int count = 0;

    dir = opendir(pathname);
    if (dir == NULL) {
        return 0;
    }

    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        count++;
    }

    closedir(dir);
    return count;
}

int fgof_fs_scandir_fill(const char *pathname, char *names, int max_entries, int stride) {
    DIR *dir;
    struct dirent *entry;
    int count = 0;

    dir = opendir(pathname);
    if (dir == NULL) {
        return 0;
    }

    while ((entry = readdir(dir)) != NULL && count < max_entries) {
        char *slot;

        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        slot = names + (count * stride);
        strncpy(slot, entry->d_name, (size_t)stride - 1);
        slot[stride - 1] = '\0';
        count++;
    }

    closedir(dir);
    return count;
}

int fgof_fs_mkdir_if_needed(const char *pathname, int mode) {
    struct stat st;

    if (stat(pathname, &st) == 0) {
        return S_ISDIR(st.st_mode) ? 1 : 0;
    }

    if (mkdir(pathname, (mode_t)mode) == 0) {
        return 1;
    }

    if (errno == EEXIST && stat(pathname, &st) == 0 && S_ISDIR(st.st_mode)) {
        return 1;
    }

    return 0;
}

int fgof_fs_unlink_path(const char *pathname) {
    return unlink(pathname) == 0 ? 1 : 0;
}

int fgof_fs_rmdir_path(const char *pathname) {
    return rmdir(pathname) == 0 ? 1 : 0;
}

int fgof_fs_rename_path(const char *source, const char *destination) {
    return rename(source, destination) == 0 ? 1 : 0;
}
