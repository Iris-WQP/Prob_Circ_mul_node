import struct
import torch

def hex_to_bfloat(hex_string):
    # 使用int函数将十六进制字符串转换为整数
    int_value = int(hex_string, 16)

    # 使用float函数将整数转换为浮点数
    float_value = float.fromhex(hex(int_value))

    # 使用torch.bfloat16函数将浮点数转换为bfloat16
    torch_float_value = torch.tensor(float_value)
    bfloat_value = torch_float_value.to(torch.bfloat16)

    return bfloat_value

def bfloat_to_hex(f):
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)
    
    # 将二进制数据转换为十六进制字符串
    hex_string = ''.join(format(byte, '02x') for byte in b)
    bfloat_hex_string = hex_string[0:4]
    return bfloat_hex_string

        # mode0 ---- two inputs
        # mode1 ---- three inputs
        # mode2 ---- four inputs
        # mode3 ---- six inputs      

if __name__ == "__main__":

    mode = 0
    input_path = 'stim_inputs.txt'
    software_output_path = 'soft_outputs.txt'
    hardware_output_path = 'stim_outputs.txt'
    # 从文本文件中逐行读取十六进制数
    with open(input_path, 'r') as file:
        hex_string = file.readline().strip()
        while hex_string:
            bfloat_inputs = [0, 0, 0, 0, 0, 0, 0, 0]
            results = [0, 0, 0, 0]
            results_hex = ""
            # 将十六进制数转换为BF16
            for i in range (8):
                bfloat_inputs[i] = hex_to_bfloat(hex_string[i*4:i*4+4])
                # 如果bfloat_inputs为subnormal数，将其转换为0
                if bfloat_inputs[i] < 1e-126 and bfloat_inputs[i] > -1e-126:
                    bfloat_inputs[i] = 0                
                print("bfloat_inputs[i]"+str(bfloat_inputs[i]))
                hex_string = file.readline().strip()
            if mode == 0:
                results[0] = bfloat_inputs[0] * bfloat_inputs[1]
                results[1] = bfloat_inputs[2] * bfloat_inputs[3]
                results[2] = bfloat_inputs[4] * bfloat_inputs[5]
                results[3] = bfloat_inputs[6] * bfloat_inputs[7]
                for j in range(4):
                    if results[j] < 1e-126 and results[j] > -1e-126:
                        results[j] = 0                  
                    result_hex = "".join(bfloat_to_hex(results[j]))
                    print(result_hex)
                    # 将结果写入文本文件output_path，每行一个结果
                    with open(software_output_path, 'a') as output_file:
                        output_file.write(result_hex)
                        output_file.write('\n')
    
    # software_output_path和hardware_output_path中的结果逐行比较
    with open(software_output_path, 'r') as output_file:
        with open(hardware_output_path, 'r') as hardware_output_file:
            output_hex = output_file.readline().strip()
            hardware_output_hex = hardware_output_file.readline().strip()
            while output_hex:
                if output_hex != hardware_output_hex:
                    print("Error!")
                    print("output_hex: "+output_hex)
                    print("hardware_output_hex: "+hardware_output_hex)
                    break
                output_hex = output_file.readline().strip()
                hardware_output_hex = hardware_output_file.readline().strip()
            print("Done. All results are correct!")