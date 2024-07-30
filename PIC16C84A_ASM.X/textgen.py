#!/usr/bin/env python3

tekst0 = "Jeden"
tekst1 = "Dwa"
tekst2 = "Trzy"
tekst3 = "Cztery"

def print_string_as_16fdata(tekst):
	for char in tekst:
		print("\t retlw \'{}\'".format(char))
	print("\t retlw 0x00")
	return

print("text0_data:")
print_string_as_16fdata(tekst0)
print()
print("text1_data:")
print_string_as_16fdata(tekst1)
print()
print("text2_data:")
print_string_as_16fdata(tekst2)
print()
print("text3_data:")
print_string_as_16fdata(tekst3)
print()
