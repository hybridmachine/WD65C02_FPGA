# This Python script reads intel hex and outputs into VHD ROM
# This script was created in collaboration with ChatGPT 4 Sep 25,2023 version
import argparse

def parse_intel_hex(hex_lines):
    """Parse Intel HEX format lines and return a dictionary of address to data bytes."""
    data_dict = {}
    for line in hex_lines:
        if line.startswith(':'):
            line = line[1:].strip()
            record_length = int(line[0:2], 16)
            address = int(line[2:6], 16)
            record_type = int(line[6:8], 16)
            if record_type == 0:
                data_bytes = [int(line[i:i+2], 16) for i in range(8, 8 + record_length * 2, 2)]
                for i, byte in enumerate(data_bytes):
                    data_dict[address + i] = byte
    return data_dict

def convert_hex_to_vhd(hex_lines, start_address, end_address):
    """Convert Intel HEX lines to VHD ROM format based on start and end addresses."""
    data_dict = parse_intel_hex(hex_lines)
    vhd_content = []
    address = start_address
    while address <= end_address:
        data_bytes = [data_dict.get(address + i, 0) for i in range(4)]
        hex_string = ''.join(f'{byte:02X}' for byte in data_bytes)
        vhd_content.append(hex_string)
        address += 4
    return vhd_content

def format_as_vhd_hex(data_lines):
    """Format the data lines into VHD hex strings."""
    vhd_formatted = []
    for line in data_lines:
        vhd_line = ', '.join([f'x"{line[i:i+2]}"' for i in range(0, len(line), 2)])
        vhd_formatted.append(vhd_line)
    return vhd_formatted

def replace_vhd_data(vhd_template, new_data, pad_length=256):
    """Replace the data section in the VHD template with new data, and pad to the specified length."""
    start_tag = "-- ROM CONTENT BEGIN"
    end_tag = "-- ROM CONTENT END"
    start_index = vhd_template.find(start_tag)
    end_index = vhd_template.find(end_tag)
    if start_index == -1 or end_index == -1:
        return "Error: Could not find data section tags in VHD template."
    header = vhd_template[:start_index + len(start_tag)]
    footer = vhd_template[end_index:]
    pad_count = pad_length - len(new_data)
    padding = [f'x"00", x"00", x"00", x"00"' for _ in range(pad_count)]
    padded_data = new_data + padding
    new_vhd_content = header + '\n' + ',\n'.join(padded_data) + '\n' + footer
    return new_vhd_content


# Existing functions (parse_intel_hex, convert_hex_to_vhd, format_as_vhd_hex, replace_vhd_data) here

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert Intel HEX to VHD ROM format.')
    parser.add_argument('--hex_file', required=True, help='Path to the Intel HEX file.')
    parser.add_argument('--vhd_template', required=True, help='Path to the template VHD file.')
    parser.add_argument('--start_address', required=True, type=lambda x: int(x, 0),
                        help='Start address in hex (e.g., 0xFC00).')
    parser.add_argument('--end_address', required=True, type=lambda x: int(x, 0),
                        help='End address in hex (e.g., 0xFCFF).')
    parser.add_argument('--output_vhd', required=True, help='Path to the output VHD file.')

    args = parser.parse_args()

    # Read the HEX file
    with open(args.hex_file, 'r') as f:
        hex_lines = f.readlines()

    # Read the VHD template
    with open(args.vhd_template, 'r') as f:
        vhd_template = f.read()

    # Convert and format the data
    converted_data = convert_hex_to_vhd(hex_lines, args.start_address, args.end_address)
    formatted_data = format_as_vhd_hex(converted_data)

    # Replace the data section in the VHD template and save to output file
    new_vhd_content = replace_vhd_data(vhd_template, formatted_data)
    with open(args.output_vhd, 'w') as f:
        f.write(new_vhd_content)
