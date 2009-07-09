import os


VersionTemplate     = "      character*48 :: dsm2_version = '8.0a4  Subversion: @Version_SVN@' " 
VersionFile_path    = "./version.inc"





VersionFile = open(VersionFile_path, "w") 

try:
    (dummy, SVNVersion_SourceCode) = os.popen4("svnversion D:/delta/models/dsm2 ")
    SVNVersion_SourceCode = SVNVersion_SourceCode.readlines()[0]
    SVNVersion_SourceCode = SVNVersion_SourceCode.strip()

    print ' SVN version of D:/delta/models/dsm2:        '+ SVNVersion_SourceCode
    VersionTxt = VersionTemplate.replace("@Version_SVN@", SVNVersion_SourceCode)
    VersionFile.write(VersionTxt)
    VersionFile.close()
   

except:
    VersionFile.close()
    os.remove(VersionFile_path) 
    print 'Abort.... possible error in file D:/delta/models/dsm2/src/common/verion_generate.py'    
