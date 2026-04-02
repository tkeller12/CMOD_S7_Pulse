from setuptools import setup, find_packages

setup(
    name="pypulsegen",
    version="0.1.0",
    packages=find_packages(),
    install_requires=["pyserial"],
    author="Your Name",
    author_email="your.email@example.com",
    description="A Python package for generating FPGA pulse sequences",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/pypulsegen",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
)
