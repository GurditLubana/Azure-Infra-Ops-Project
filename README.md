Type az --version on vscode
if you get the response that az is not recognzied, then you gonna have to install az CLI on your VS code using the command below

winget install -e --id Microsoft.AzureCLI

or what you can do is, you can go to Azure portal and use the azure CLI from there. 

once the az cli is ready to use, try and type az bicep version and check if you have bicep or not. if not then install that as well using az bicep install


then try to do some validations locally. run  az bicep build --file .\infrastructure\main.bicep and then run  az bicep lint --file .\infrastructure\main.bicep

if there are no errors. then run az login

after loggin you can check if you have the correct subscription or not by running az account show --output table

and if everything is right. you can now start validating your project through azure by running the command below

az deployment sub validate --name aiol-phase3-validate --location eastus2 --template-file .\infrastructure\main.bicep --parameters "@.\infrastructure\main.parameters.dev.json"


if you see errors, fix them. if there are no errors then you should be seeing a json like output on your console. this means, there were no errors

Now if validation is passed, we will now try to run a what-if situation, using the command below bicep will try and ask azure if i deploy the resources below, what will you deploy/change/update. 