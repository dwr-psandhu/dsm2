import os

Version_Main    = "8.0"  # First two number of 8.0b1
Version_Status  = "b2"   # Beta 2

setupfile = open("DSM2setup_v8.iss","w")
setupTemplate = open("DSM2setup_v8.template",'r')




(dummy, SVNVersion_SourceCode) = os.popen4("svnversion ../../../dsm2 ")
(dummy, SVNVersion_Distribute) = os.popen4("svnversion ../../../dsm2_distribute/dsm2 ")

SVNVersion_SourceCode = SVNVersion_SourceCode.readlines()[0]
SVNVersion_Distribute = SVNVersion_Distribute.readlines()[0]

SVNVersion_SourceCode = SVNVersion_SourceCode.strip()
SVNVersion_Distribute = SVNVersion_Distribute.strip()


print ' SVN version of ../../../dsm2:                 '+ SVNVersion_SourceCode
print ' SVN version of ../../../dsm2_distribute/dsm2: '+ SVNVersion_Distribute

try:
    #test = int(SVNVersion_SourceCode)
    #test = int(SVNVersion_Distribute)

    setupTemplateTxt = setupTemplate.read()
   
    setupTemplateTxt = setupTemplateTxt.replace("@{Version_Main}",        Version_Main)
    setupTemplateTxt = setupTemplateTxt.replace("@{Version_Distribute}", SVNVersion_Distribute)
    setupTemplateTxt = setupTemplateTxt.replace("@{Version_SourceCode}", SVNVersion_SourceCode)
    setupTemplateTxt = setupTemplateTxt.replace("@{Version_Status}",     Version_Status)
    
    setupfile.write(setupTemplateTxt)
    setupfile.close()
        

except:
    print 'Abort.... Try SVN update and commit before generating setup script.'
    