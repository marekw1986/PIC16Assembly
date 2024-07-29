#!/usr/bin/env python3

tekst1 = "Pierwszy napis"
tekst2 = "Drugi napis"
tekst3 = "Trzeci napis"
tekst4 = "Czwarty napis"

def print_string_as_16fdata(tekst):
	for char in tekst:
		print("\t retlw \'{}\'".format(char))
	print("\t retlw 0x00")
	return

print("text1_data:")
print_string_as_16fdata(tekst1)
print()
print("text2_data:")
print_string_as_16fdata(tekst2)
print()
print("text3_data:")
print_string_as_16fdata(tekst3)
print()
print("text4_data:")
print_string_as_16fdata(tekst4)
print()
