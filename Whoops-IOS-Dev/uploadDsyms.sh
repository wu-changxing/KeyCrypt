ditto -x -k --sequesterRsrc --rsrc appDsyms.zip ./dsyms
./Pods/FirebaseCrashlytics/upload-symbols -gsp ./Whoops/GoogleService-Info.plist -p ios ./dsyms
rm -r ./dsyms
echo "Done!"