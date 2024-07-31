#!/usr/bin/env python3

from io import BytesIO
from io import StringIO
from baudot import encode_str, decode_to_str, codecs, handlers

tekst0 = "JEDEN"
tekst1 = "DWA"
tekst2 = "TRZY"
tekst3 = "CZTERY"

def print_string_as_16fdata(tekst):
	output = []
	with BytesIO() as output_buffer:
		writer = handlers.HexBytesWriter(output_buffer)
		encode_str(tekst, codecs.ITA2_STANDARD, writer)
		output_buffer.seek(0)
		while True:
			hex_byte = output_buffer.read(2)
			if not hex_byte:
				break
			output.append(int(hex_byte, 16))
	
	for byte in output:
		print("\t retlw {}".format(hex(byte)))
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
