# BGInfo
Installs BGInfo for use with NinjaRemote or you can do this with anything.

I was inspired to write an actual BGInfo automation.  I conjunction with ChatGPT, I was able to troubleshoot this script to work in the most efficient manner.

1.  On your host computer, you will want to run the BGInfo64.exe.  Make sure you accept eula, and then the window appears.  You must click the timer (because it will count down from 10 seconds) in order to stop the timer and move forward.
  A.  Customize what information you would like to appear.  Mine is very simple, and there are plenty of walkthroughs and ChatGPT to help you understand how to do the custom information you would like to appear.  In my case, I didn't like the way the IP addresses were showing up because there were (null) values showing as well as the IPv4 and IPv6.  I customized the Get-IPAddress.ps1 script to only obtain the IPv4 address, and save it to a text file called IPAddress.txt (which will be automatically created when running the bginfoScript-version2.ps1 on the target machine or through the automation in Ninja).
  B.  Save the configuration to where ever you want, but document where so you can refer to the path of that .bgi configuration file later (I named mine, and you can use it as bgDisplay.bgi).
  C.  That's it for this step and can move on to NinjaRemote setup!

3.  When setting up the automation in NinjaOne:
  A.  You will need to ADD a automation for INSTALL APPLICATION and go through the settings for that automation.  Save and exit this automation, for you will then want to write the script automation in next step.  I named my install application BGInfo.
  B.  You will need to ADD a automation for SCRIPT and set the bginfoScript-version2.ps1 contents in that code space (open up this file in your text editor and copy and paste the contents to the code input area).
  C.  Once these are completed, you can edit your BGInfo automation (Install Application) and add /SILENT /TIMER:0 /ACCEPTEULA parameters.  Save those parameters and check the box for keeping those as the default.
  D.  Upload the .exe for BGInfo.exe or BGInfo64.exe (my script is based on BGInfo64.exe, so you may have to change these in the script if using regular bginfo.exe).
  E.  On the additional tab of the BGInfo automation, you will add the Get-IPAddress.ps1, bgDisplay.bgi, and BGinfo64.exe (yes, I had to upload it here as well because the main script will copy those files to the target machines C:\BGInfo folder it creates).
  F.  In the "Add a post script" area, this is where you click and add that other SCRIPT AUTOMATION you created earlier.  I named my automation script in Ninja bginfoScript.
  G.  Once you are done you can save that and you will have to wait for Ninja to approve.  Once it is approved you should be good to go with running the App install automation of BGInfo.

Of course with everything test it first on one machine.  If successful, you are ready to start applying it to a policy in your organization of choice (if you are admin).  This should work following the directions.

If you need to customize according to your settings go ahead, this is just a nice backbone to whatever you need to do.  Just remember to change your paths and anything related to anything in your setting for this to work smoothly.

This automation runs within a minute from start to finish (at least the way you have to wait for Ninja to process this and execute).  It is pretty streamlined so happy to share this with everyone!
