package joke

/*
License for creative work of Cowsay
==============
cowsay License
==============

cowsay is distributed under the same licensing terms as Perl: the
Artistic License or the GNU General Public License.  If you don't
want to track down these licenses and read them for yourself, use
the parts that I'd prefer:

(0) I wrote it and you didn't.

(1) Give credit where credit is due if you borrow the code for some
other purpose.

(2) If you have any bugfixes or suggestions, please notify me so
that I may incorporate them.

(3) If you try to make money off of cowsay, you suck.

===============
cowsay Legalese
===============

(0) Copyright (c) 1999 Tony Monroe.  All rights reserved.  All
lefts may or may not be reversed at my discretion.

(1) This software package can be freely redistributed or modified
under the terms described above in the "cowsay License" section
of this file.

(2) cowsay is provided "as is," with no warranties whatsoever,
expressed or implied.  If you want some implied warranty about
merchantability and/or fitness for a particular purpose, you will
not find it here, because there is no such thing here.

(3) I hate legalese.
*/

/*
Changelog:

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, some adaptation apply: https://keepachangelog.com/en/1.1.0/
This project also adheres to Semantic Versioning: https://semver.org/spec/v2.0.0.html

[0.1.0] 2026-08-09
	Initial release
*/

import "base:runtime"
import "core:c"
import "core:c/libc"
import "core:encoding/json"
import "core:fmt"
import "core:os"
import "vendor:curl"

cowsay :: proc(text: string, cow: string) {
	len := len(text)
	width := len + 2
	fmt.printf(" ")
	for i := 0; i < width; i += 1 {
		fmt.printf("_")
	}
	fmt.printf("\n")
	fmt.printf("< %s >\n", text)
	fmt.printf(" ")
	for i := 0; i < width; i += 1 {
		fmt.printf("-")
	}
	fmt.printf("\n")
	fmt.printf("%s\n", cow)
}

cow1 ::
`      \   ^__^
       \  (oo)\_______
          (__)\       )\/\
              ||----w |
              ||     ||`

cow2 ::
`      \   ^__^
       \  (^^)\_______
          (__)\       )\/\
              ||----w |
              ||     ||`

WriteCallback :: proc "c" (
	contents: rawptr,
	size: c.size_t,
	nmemb: c.size_t,
	userp: rawptr,
) -> c.size_t {
	total := int(size * nmemb)

	response := cast(^[dynamic]u8)userp
	bytes := cast([^]u8)contents

	context = runtime.default_context()
	append(response, ..bytes[:total])

	return size * nmemb
}

Response :: struct {
	type:      string,
	setup:     string,
	punchline: string,
	id:        uint,
}

move_up :: proc(n: int) {fmt.printf("\033[%dA", n)}

clear_line :: proc() {fmt.printf("\033[2K")}

main :: proc() {
	Curl := curl.easy_init()

	if Curl != nil {
		curl.easy_setopt(
			Curl,
			curl.option.URL,
			"https://official-joke-api.appspot.com/random_joke",
		)

		response: [dynamic]u8

		curl.easy_setopt(Curl, curl.option.WRITEFUNCTION, WriteCallback)
		curl.easy_setopt(Curl, curl.option.WRITEDATA, &response)

		res := curl.easy_perform(Curl)

		if res == curl.code.E_OK {
			R: Response

			err := json.unmarshal(response[:], &R)
			if err != nil {
				fmt.println(err)
				os.exit(1)
			}

			cowsay(R.setup, cow1)

			libc.fgetc(libc.stdin)

			move_up(7)
			for i := 0; i < 7; i += 1 {
				clear_line()
				fmt.print("\033[1B")
			}
			move_up(7)

			cowsay(R.punchline, cow2)
		} else {
			fmt.printf("Request failed:", curl.easy_strerror(res))
		}

		curl.easy_cleanup(Curl)
	}
}

