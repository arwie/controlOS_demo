// Copyright (c) 2016 Artur Wiebe <artur@4wiebe.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#ifndef AMCS_H_
#define AMCS_H_


#define NO_STRING_TYPE		0		/* No type */
#define ASCII8_STRING_TYPE	1		/* ASCII-8 type */
#define UTF8_STRING_TYPE 	2		/* UTF-8 type */


extern "C" {

	struct SYS_STRING;

	extern int str_GetNumBytes (SYS_STRING* string);
	extern unsigned char* str_GetData(SYS_STRING* string);
	extern SYS_STRING* str_GetString(unsigned char* data, int data_size, int type);

}



static inline string amcsGetString(SYS_STRING* mcString)
{
	return string((const char*)str_GetData(mcString));
}


//static inline SYS_STRING* amcsNewMcString(const string& str)
//{
//	auto mcString = str_GetString((unsigned char*)str.c_str(), str.length(), ASCII8_STRING_TYPE);
//
//	if (mcString == NULL)
//		throw exception();
//
//	return mcString;
//}

#endif /* AMCS_H_ */
