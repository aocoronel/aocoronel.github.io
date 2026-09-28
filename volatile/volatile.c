/*
Changelog:

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, some adaptation apply: https://keepachangelog.com/en/1.1.0/
This project also adheres to Semantic Versioning: https://semver.org/spec/v2.0.0.html

[0.1.0] 2026-08-09
	Initial release
*/

#define _XOPEN_SOURCE 700

#include <dirent.h>
#include <getopt.h>
#include <regex.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct Regex_Node Regex_Node;

struct Regex_Node {
    regex_t regex;
    Regex_Node *next;
};

Regex_Node *allowlist = NULL;

struct option long_options[] = {
    { "debug",     no_argument,       0, 'D' },
    { "dry",       no_argument,       0, 'd' },
    { "file",      required_argument, 0, 'f' },
    { "help",      no_argument,       0, 'h' },
    { "invert",    no_argument,       0, 'i' },
    { "recursive", no_argument,       0, 'i' },
    { "verbose",   no_argument,       0, 'V' },
    { 0,           0,                 0, 0   }
};

bool DRY_MODE = false;
bool VERBOSE = false;
bool DEBUG_MODE = false;
bool INVERT = false;
bool RECURSIVE = false;

char *allow_file = "allowlist.txt";

int is_allowed(const char *filename, const char *fullpath) {
    for (Regex_Node *n = allowlist; n; n = n->next) {
        if (regexec(&n->regex, filename, 0, NULL, 0) == 0) return 1;
        if (regexec(&n->regex, fullpath, 0, NULL, 0) == 0) return 1;
    }
    return 0;
}

void on_allowed(const char *path) {
    if (VERBOSE) printf("Allowed: %s\n", path);
}

int load_allowlist(const char *filename) {
    FILE *f = fopen(filename, "r");
    if (!f) return 0;

    char line[512];
    while (fgets(line, sizeof(line), f)) {
        line[strcspn(line, "\n")] = 0;
        if (*line == '\0') continue;

        Regex_Node *node = malloc(sizeof(Regex_Node));
        if (!node) continue;
        if (regcomp(&node->regex, line, REG_NOSUB | REG_EXTENDED) != 0) {
            fprintf(stderr, "error: invalid regex: %s\n", line);
            exit(1);
        }
        node->next = allowlist;
        allowlist = node;
    }
    fclose(f);
    return 1;
}

void free_allowlist(void) {
    Regex_Node *n = allowlist;
    while (n) {
        Regex_Node *tmp = n->next;
        regfree(&n->regex);
        free(n);
        n = tmp;
    }
    allowlist = NULL;
}

int remove_directory(const char *path) {
    struct dirent *entry;
    DIR *dir = opendir(path);
    if (!dir) {
        perror("opendir");
        return -1;
    }

    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;

        char full_path[4096];
        snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);

        struct stat statbuf;
        if (lstat(full_path, &statbuf) == 0) {
            if (S_ISLNK(statbuf.st_mode)) {
                if (unlink(full_path) != 0) {
                    perror("unlink symlink");
                    closedir(dir);
                    return -1;
                }
            } else if (S_ISDIR(statbuf.st_mode)) {
                if (remove_directory(full_path) != 0) {
                    closedir(dir);
                    return -1;
                }
            } else {
                if (unlink(full_path) != 0) {
                    perror("unlink file");
                    closedir(dir);
                    return -1;
                }
            }
        } else {
            perror("lstat");
            closedir(dir);
            return -1;
        }
    }
    closedir(dir);
    if (rmdir(path) != 0) {
        perror("rmdir");
        return -1;
    }
    return 0;
}

void traverse(const char *path) {
    DIR *dir = opendir(path);
    if (!dir) return;

    struct dirent *entry;
    char fullpath[4096];
    int empty = 1;

    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;

        snprintf(fullpath, sizeof(fullpath), "%s/%s", path, entry->d_name);
        if (DEBUG_MODE) {
            fprintf(stderr, "debug: entry name: %s\n", entry->d_name);
            fprintf(stderr, "debug: path: %s\n", path);
            fprintf(stderr, "debug: full Path: %s\n", fullpath);
        }
        struct stat st;
        if (lstat(fullpath, &st) == -1) continue;

        empty = 0;

        if (S_ISDIR(st.st_mode)) {
            if (RECURSIVE) {
                traverse(fullpath);
            } else {
                if (is_allowed(entry->d_name, fullpath)) {
                    if (INVERT) {
                        // Disallowed
                        if (!DRY_MODE) {
                            int err = remove_directory(fullpath);
                            if (err == -1) {
                                fprintf(stderr, "error: failed to delete dir\n");
                                continue;
                            }
                        }
                        if (VERBOSE) printf("RM [DIR]: %s\n", fullpath);
                    } else {
                        // Allowed
                        on_allowed(fullpath);
                    }
                } else {
                    if (INVERT) {
                        // Allowed
                        on_allowed(fullpath);
                    } else {
                        // Disallowed
                        if (!DRY_MODE) {
                            int err = remove_directory(fullpath);
                            if (err == -1) {
                                fprintf(stderr, "error: failed to delete dir\n");
                                continue;
                            }
                        }
                        if (VERBOSE) printf("RM [DIR]: %s\n", fullpath);
                    }
                }
            }
        } else if (S_ISREG(st.st_mode)) {
            if (is_allowed(entry->d_name, fullpath)) {
                if (INVERT) {
                    // Disallowed
                    if (!DRY_MODE) remove(fullpath);
                    if (VERBOSE) printf("RM [FILE]: %s\n", fullpath);
                } else
                    // Allowed
                    on_allowed(fullpath);
            } else {
                if (INVERT) {
                    // Allowed
                    on_allowed(fullpath);
                } else {
                    // Disallowed
                    if (!DRY_MODE) remove(fullpath);
                    if (VERBOSE) printf("RM [FILE]: %s\n", fullpath);
                }
            }
        }
    }
    closedir(dir);

    DIR *check = opendir(path);
    if (!check) return;

    empty = 1;
    while ((entry = readdir(check)) != NULL) {
        if (strcmp(entry->d_name, ".") && strcmp(entry->d_name, "..")) {
            empty = 0;
            break;
        }
    }
    closedir(check);

    if (empty) {
        if (VERBOSE) printf("RM [DIR]: %s\n", path);
        if (!DRY_MODE) rmdir(path);
    }
}

void help(void) {
    printf("volatile | Wipe files using a whitelist or blacklist\n\n"
           "Usage:  volatile [OPTIONS] [DIR]\n\n"
           "Options:\n"
           "  -D, --debug\n"
           "          Enable debug mode\n"
           "  -V, --verbose\n"
           "          Enable verbosity\n"
           "  -d, --dry\n"
           "          Preview actions\n"
           "  -f, --file <FILE>\n"
           "          Use an alternative allowlist file\n"
           "  -h, --help\n"
           "          Displays this message and exits\n"
           "  -i, --invert\n"
           "          Enable blacklist mode\n");
    exit(0);
}

int main(int argc, char **argv) {
    int opt = 0;
    const char *working_dir = NULL;

    while ((opt = getopt_long(argc, argv, ":dDrVhf:ir", long_options, NULL)) != -1) {
        switch (opt) {
        case 'd':
            DRY_MODE = true;
            break;
        case 'f':
            allow_file = optarg;
            break;
        case 'V':
            VERBOSE = true;
            break;
        case 'i':
            INVERT = true;
            break;
        case 'D':
            DEBUG_MODE = true;
            break;
        case 'r':
            RECURSIVE = true;
            break;
        case 'h':
            help();
        case ':':
            fprintf(stderr, "error: option '%c' needs a value\n", opt);
            break;
        case '?':
            fprintf(stderr, "error: unknown option: %c\n", optopt);
            break;
        }
    }

    if (optind < argc) {
        working_dir = argv[optind++];
    }

    if (!working_dir) working_dir = ".";

    if (!load_allowlist(allow_file)) {
        fprintf(stderr, "error: failed to load regex allowlist\n");
        return 1;
    }

    if (INVERT) printf("Using volatile as blacklist mode\n");
    if (!INVERT) printf("Using volatile as whitelist mode\n");

    traverse(working_dir);

    free_allowlist();
    return 0;
}
