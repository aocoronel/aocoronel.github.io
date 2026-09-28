/*
Changelog:

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, some adaptation apply: https://keepachangelog.com/en/1.1.0/
This project also adheres to Semantic Versioning: https://semver.org/spec/v2.0.0.html

[0.1.0] 2026-08-09
	Initial release
*/

#include <arpa/inet.h>
#include <assert.h>
#include <stdbool.h>
#include <netinet/in.h>
#include <openssl/bn.h>
#include <openssl/evp.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/cdefs.h>
#include <sys/socket.h>
#include <unistd.h>

#define ASSERT_NONNULL(exp) assert((exp) && "passing NULL pointer to Nonnull parameter")
#define eprintf(...) fprintf(stderr, __VA_ARGS__)

#define CHAR_LOWER "abcdefghijklmnopqrstuvwxyz"
#define CHAR_UPPER "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define DIGITS "0123456789"
#define SYMBOLS "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"

#define PASSWORD_LENGTH 35
#define HASH_LENGTH 32
#define PBKDF2_ITERATIONS 100000

const char ALL_CHARS[256] = CHAR_LOWER CHAR_UPPER DIGITS SYMBOLS;
const char *RULE_SETS[] = { CHAR_LOWER, CHAR_UPPER, DIGITS, SYMBOLS };
#define RULE_COUNT 4

BIGNUM *divisor = NULL;
BIGNUM *quotient = NULL;
BIGNUM *_remainder = NULL;

char consume_char(BIGNUM *entropy, const char *chars, BN_CTX *ctx) {
    ASSERT_NONNULL(entropy);
    ASSERT_NONNULL(chars);
    ASSERT_NONNULL(ctx);

    BN_set_word(divisor, strlen(chars));
    BN_div(quotient, _remainder, entropy, divisor, ctx);
    unsigned long rem = BN_get_word(_remainder);
    BN_copy(entropy, quotient);
    char result = chars[rem];

    return result;
}

void insert_char(char *str, char ch, int index, int len) {
    ASSERT_NONNULL(str);
    int i;
    if (index < 0) index = 0;
    if (index > len) index = len;
    for (i = len; i >= index; i--) {
        str[i + 1] = str[i];
    }
    str[index] = ch;
}

bool generate_password(const char *site,
                       const char *login,
                       const char *master_password,
                       int counter,
                       char *output) {
    ASSERT_NONNULL(site);
    ASSERT_NONNULL(login);
    ASSERT_NONNULL(master_password);
    ASSERT_NONNULL(output);

    BIGNUM *entropy;
    BN_CTX *ctx;
    char extra[RULE_COUNT];
    char password[128] = { 0 };
    char salt[512];
    int base_len = 0;
    int i = 0;

    snprintf(salt, sizeof(salt), "%s%s%x", site, login, counter);

    unsigned char hash[HASH_LENGTH];

    PKCS5_PBKDF2_HMAC(master_password,
                      strlen(master_password),
                      (unsigned char *)salt,
                      strlen(salt),
                      PBKDF2_ITERATIONS,
                      EVP_sha256(),
                      HASH_LENGTH,
                      hash);

    entropy = BN_bin2bn(hash, HASH_LENGTH, NULL);
    if (!entropy) return false;

    ctx = BN_CTX_new();
    if (!ctx) {
        BN_free(entropy);
        return false;
    }

    base_len = PASSWORD_LENGTH - RULE_COUNT;

    for (i = 0; i < base_len; i++) {
        password[i] = consume_char(entropy, ALL_CHARS, ctx);
    }

    password[base_len] = '\0';

    for (i = 0; i < RULE_COUNT; i++) {
        extra[i] = consume_char(entropy, RULE_SETS[i], ctx);
    }

    for (i = 0; i < RULE_COUNT; i++) {
        BN_set_word(divisor, strlen(password));
        BN_div(quotient, _remainder, entropy, divisor, ctx);
        int index = BN_get_word(_remainder);
        BN_copy(entropy, quotient);
        insert_char(password, extra[i], index, strlen(password));
    }

    strcpy(output, password);

    memset(password, 0, sizeof(password));

    BN_free(entropy);
    BN_CTX_free(ctx);

    return true;
}

int main(int argc, char **argv) {
    if (argc < 4) {
        eprintf("Usage: tinypass [site] [login] [password] [counter]\n");
        return 1;
    }

    const char *site = argv[1];
    const char *login = argv[2];
    const char *master_password = argv[3];

    int counter = 0;

    if (argc >= 5) {
        counter = atoi(argv[4]);
        /* On error, atoi() returns 0 */
        if (counter == 0) counter = 1;
    }

    char password[128];

    divisor = BN_new();
    quotient = BN_new();
    _remainder = BN_new();

    generate_password(site, login, master_password, counter, password);

    BN_free(divisor);
    BN_free(quotient);
    BN_free(_remainder);

    printf("%s\n", password);

    memset(password, 0, sizeof(password));

    return 0;
}
