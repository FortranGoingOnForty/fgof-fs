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

int fgof_fs_copy_file(const char *source, const char *destination) {
    FILE *src;
    FILE *dst;
    unsigned char buffer[8192];
    size_t read_count;

    src = fopen(source, "rb");
    if (src == NULL) {
        return 0;
    }

    dst = fopen(destination, "wb");
    if (dst == NULL) {
        fclose(src);
        return 0;
    }

    while ((read_count = fread(buffer, 1, sizeof buffer, src)) > 0) {
        if (fwrite(buffer, 1, read_count, dst) != read_count) {
            fclose(src);
            fclose(dst);
            unlink(destination);
            return 0;
        }
    }

    if (ferror(src) != 0) {
        fclose(src);
        fclose(dst);
        unlink(destination);
        return 0;
    }

    fclose(src);
    if (fclose(dst) != 0) {
        unlink(destination);
        return 0;
    }

    return 1;
}
