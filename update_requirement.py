import pkg_resources

# 读取原始 requirements.txt 文件
with open('requirements.txt', 'r') as file:
    requirements = file.readlines()

# 打开新的 requirements.txt 文件准备写入
with open('new_requirements.txt', 'w') as new_file:
    for line in requirements:
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith('#'):
            if stripped_line.startswith('-e '):
                # 保持带有 -e 的行原样写入
                new_file.write(line)
            else:
                package = stripped_line.split('==')[0].split('@')[0].strip()
                try:
                    version = pkg_resources.get_distribution(package).version
                    new_file.write(f"{package}=={version}\n")
                except pkg_resources.DistributionNotFound:
                    # 如果包未找到，保持原样写入
                    new_file.write(line)
                    print(f"Warning: {package} not found in the environment. Keeping original line.")
        else:
            # 写入注释或空行
            new_file.write(line)

print("Updated requirements saved to new_requirements.txt")

