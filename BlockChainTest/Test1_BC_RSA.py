# coding=utf-8

import time
import hashlib
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import utils

'''
1 生成RSA公私钥对。
2 POW计算，找到“lmx+nonce”前4个0开头的哈希值。
3 用私钥对“lmx+nonce”进行签名，并打印签名内容。
4 用公钥验证签名，并打印验证结果。
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


def pow_with_difficulty_and_sign(prefix: str, difficulty: int):
    nonce = 0
    start_time = time.time()
    while True:
        content = f"{prefix}{nonce}"
        hash_result = hashlib.sha256(content.encode('utf-8')).hexdigest()
        if hash_result.startswith('0' * difficulty):
            end_time = time.time()
            print(f"难度: {difficulty} 个 0")
            print(f"耗时: {end_time - start_time:.4f} 秒")
            print(f"内容: {content}")
            print(f"Hash值: {hash_result}\n")

            # 用私钥对内容签名
            signature = private_key.sign(
                content.encode('utf-8'),
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
            print(f"签名: {signature.hex()}")

            # 用公钥验证签名
            try:
                public_key.verify(
                    signature,
                    content.encode('utf-8'),
                    padding.PSS(
                        mgf=padding.MGF1(hashes.SHA256()),
                        salt_length=padding.PSS.MAX_LENGTH
                    ),
                    hashes.SHA256()
                )
                print("签名验证: 成功\n")
            except Exception as e:
                print(f"签名验证: 失败, 错误: {e}\n")
            break
        nonce += 1

if __name__ == "__main__":
    pow_with_difficulty_and_sign("lmx", 4)
