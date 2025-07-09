# coding=utf-8

import time
import hashlib
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization


'''
1 使用RSA非对称加密算法生成密钥对（仅用于演示，未参与POW计算，仅可选参与内容拼接）。
2 不断尝试“lmx”+nonce字符串，计算其SHA256哈希，直到哈希值前4个0，打印耗时、内容和哈希值。
3 再次运算直到哈希值前5个0，打印耗时、内容和哈希值。
注意：如需运行此代码，请确保已安装cryptography库。可使用如下命令安装：
pip install cryptography
'''

# 生成非对称密钥对（RSA）
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048
)
public_key = private_key.public_key()

# 将公钥序列化为字符串（可选，用于参与POW内容）
pubkey_bytes = public_key.public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
)
pubkey_str = pubkey_bytes.decode('utf-8').replace('\n', '')


def pow_with_difficulty(prefix: str, difficulty: int):
    nonce = 0
    start_time = time.time()
    while True:
        content = f"{prefix}{nonce}"
        # 也可以把公钥内容加进来: content = f"{prefix}{nonce}{pubkey_str}"
        hash_result = hashlib.sha256(content.encode('utf-8')).hexdigest()
        if hash_result.startswith('0' * difficulty):
            end_time = time.time()
            print(f"难度: {difficulty} 个 0")
            print(f"耗时: {end_time - start_time:.4f} 秒")
            print(f"内容: {content}")
            print(f"Hash值: {hash_result}\n")
            break
        nonce += 1

if __name__ == "__main__":
    pow_with_difficulty("lmx", 4)
    pow_with_difficulty("lmx", 5)
