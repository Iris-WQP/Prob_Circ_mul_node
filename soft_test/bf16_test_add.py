import struct
import torch
import os

def hex_to_bfloat(hex_string):
    # 将十六进制字符串转换为二进制字符串
    binary_string = bin(int(hex_string, 16))[2:].zfill(16)
    # print(hex_string)
    # print(binary_string)
    # 将二进制字符串转换为bfloat16
    sign = int(binary_string[0],2)
    exponent = int(binary_string[1:9],2)
    mantissa = int(binary_string[9:16],2)
    # print(sign)
    # print(exponent) 
    # print(mantissa)
    # set zero and subnormal to zero
    if exponent == 0:
        bfloat16 = torch.tensor(0).to(torch.bfloat16)
    else:
        # convert to float
        f = (-1)**sign * 2**(exponent-127) * (1+mantissa/2**7)
        # convert to bfloat16
        bfloat16 = torch.tensor(f).to(torch.bfloat16)
    return bfloat16

def bfloat_to_hex(f):
    if f < 1e-126 and f > -1e-126:
        return "0000"
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)
    
    # 将二进制数据转换为十六进制字符串
    hex_string = ''.join(format(byte, '02x') for byte in b)
    bfloat_hex_string = hex_string[0:4]
    return bfloat_hex_string

    

if __name__ == "__main__":

    error = 0


    input_path = 'adder_stim_inputs.txt'
    hardware_output_path = 'adder_stim_outputs.txt'
    print(os.getcwd())
    
    # 逐行读取十六进制数
    with open(input_path, 'r') as input_file:
        with open(hardware_output_path, 'r') as output_file:
            hex_inputs = input_file.readline().strip()
            hardware_output = output_file.readline().strip()
            while hex_inputs:
                print(hex_inputs)
                print(hardware_output)
                bfloat_inputs = [0, 0]
                soft_result = 0
                hard_result = 0
                # 将十六进制数转换为BF16
                for i in range (2):
                    bfloat_inputs[i] = hex_to_bfloat(hex_inputs[i*4:i*4+4])          
                hard_result = hex_to_bfloat(hardware_output)
                soft_result = bfloat_inputs[0] + bfloat_inputs[1]
                
                print("soft_result "+str(soft_result))
                print("hard_result "+str(hard_result))
                if soft_result != hard_result:
                    print("Error!!!!!")
                    error = 1
                hex_inputs = input_file.readline().strip()
                hardware_output = output_file.readline().strip()                   

    print(hex_to_bfloat("61d5"))
    if(error == 0):
        print("Done. All results are correct!")      





    