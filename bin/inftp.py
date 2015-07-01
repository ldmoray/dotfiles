__author__ = 'Lenny Morayniss'
'''
This projected is licensed under the terms of the MIT license.
Copyright Lenny Morayiss 2015
'''
import argparse
from ftplib import FTP_TLS
import os
import time

def upload(ftp, filename):
    ext = os.path.splitext(filename)[1]
    if ext in (".txt", ".htm", ".html"):
        ftp.storlines("STOR " + filename, open(filename))
    else:
        ftp.storbinary("STOR " + filename, open(filename, "rb"), 1024)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Copy files over ftp on loop')
    parser.add_argument('address', action='store')
    parser.add_argument('--user', action='store')
    parser.add_argument('--password', action='store')
    parser.add_argument('filename', action='store')

    args = parser.parse_args()
    ftps = FTP_TLS(args.address)
    while True:
    	ftps.login(args.user, args.password)
    	ftps.prot_p()
        upload(ftps, args.filename)
    	ftps.prot_c()
    	ftps.quit()
        time.sleep(300)
