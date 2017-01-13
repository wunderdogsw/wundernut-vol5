FROM microsoft/dotnet:1.0-sdk-projectjson
WORKDIR /secret-message

# copy project.json & nuget.config and restore as distinct layers
COPY project.json .
COPY nuget.config .
RUN dotnet restore

# copy and build everything else
COPY . .
RUN dotnet publish -c Release -o out
ENTRYPOINT ["dotnet", "out/secret-message.dll"]
