
#include <errno.h>
#include <sys/signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#ifdef linux
	#define WHEREIS "whereis"
#endif

#ifdef WIN
	#define WHEREIS "where"
#endif

typedef enum {
	REQUIRE_RESULT_FOUND,
	REQUIRE_RESULT_ERRNO,
	REQUIRE_RESULT_NOT_FOUND,
} require_result_t;

require_result_t require_check(const char *bname) {
	int exit_code = 0;
	char command[strlen(bname) + sizeof(WHEREIS) + 1];
	memset(command, 0, sizeof(command));
	sprintf(command, "%s %s", WHEREIS, bname);
	FILE *pipe = popen(command, "r");
	if(!pipe) {
		perror("FAILED TO OPEN PIPE TO COMMAND");
		return REQUIRE_RESULT_ERRNO;
	}
	char buffer[256];
	while(fgets(buffer, sizeof(buffer), pipe) != 0);
	int status = pclose(pipe);
	if(status == -1) {
		perror("FAILED TO CLOSE PIPE");
		return REQUIRE_RESULT_ERRNO;
	}
	if(WIFEXITED(status)) {
		int code = WEXITSTATUS(status);
		if(code != 0) {
			fprintf(stderr, "COULD NOT FIND %s\n", bname);
			return REQUIRE_RESULT_NOT_FOUND;
		}
		return REQUIRE_RESULT_FOUND;
	}
	else {
		perror("FAILED TO CLOSE PIPE GRACEFULLY");
		return REQUIRE_RESULT_ERRNO;
	}
}

#define REQUIRE(bname) do {                                             \
    switch(require_check(bname)) {                                       \
        case REQUIRE_RESULT_FOUND:                                       \
            printf("ABLE TO FIND REQUIREMENT: %s\n", (bname));           \
            break;                                                       \
        case REQUIRE_RESULT_NOT_FOUND:                                   \
            fprintf(stderr, "UNABLE TO FIND REQUIREMENT: %s\n", (bname)); \
            exit(1);                                                     \
        case REQUIRE_RESULT_ERRNO:                                       \
            perror("UNABLE TO CHECK REQUIREMENT");                       \
            exit(errno);                                                 \
    }                                                                    \
} while(0)

void check_lsp() {
	printf("CHECKING LSP\n");
	REQUIRE("clangd");
	REQUIRE("rust-analyzer");
}


int main(int argc, char **argv) {
	check_lsp();
}
