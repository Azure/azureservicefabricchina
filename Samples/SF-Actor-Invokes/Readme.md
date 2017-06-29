The sample demos three types of communications between 'client' and actor:
1. native console talks with actor within service fabric cluster
2. SF webapi as gateway talks with actor 
   eg. browse http://localhost:8431/api/values/ after launch the sample in VS, return result will be ["value1","4"]
3. Stateless micro service as gateway talks with actor
