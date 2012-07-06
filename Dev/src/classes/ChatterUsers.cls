/*
  ##############################################################
  # Project Name..........: Passport
  # File..................: ChatterUsers.cls
  # Version...............: 1
  # Created by............: Kamal Ranjan
  # Created Date..........: 13-May-2012
  # Last Modified by......:    
  # Last Modified Date....:   
  # Description...........: This is a Helper class which creates chatter
  #                         users and groups for passport testing
  ########################################################################### 


1. Creates 2000 users -  chatter free - Done
2. * Uploads profile pictures for 1000 of these users (apparently cannot be done with Apex - so ignore this part and we will need to manually add the pictures to as many users as possible)
3. Puts up random information in the profile section of ALL 2000 users - Done
4. Makes each one of these 2000 users follow 20 other users each - Done
5. Creates 500 groups - 250 public, 250 private - Done
6. Inserts 100 users into each group - Done
7. Inserts all 2000 users in one public group - Done


*/
public class ChatterUsers {

    Integer noOfChatterUsers;
    Integer noOfPublicGroups;
    Integer noOfPrivateGroups;
    
    public ChatterUsers()
    {
        noOfChatterUsers = 2000;
        noOfPublicGroups = 250;
        noOfPrivateGroups = 250;

        //noOfChatterUsers = 2;     // TO DO: For testing, wl be removed after testing
        //noOfPublicGroups = 1;     // TO DO: For testing, wl be removed after testing
        //noOfPrivateGroups = 1;        // TO DO: For testing, wl be removed after testing
    }
    
    /**************************************************************************** 
    Method createPassportChatterUsers will create the passport chatter users.
    ****************************************************************************/
    public List<User> createPassportChatterUsers()
    {
        List<User> newUsersList = new List<User>();
        
        Profile p = [select id from profile where Name = 'Chatter Free User'];
        
        for(integer i = 0; i < noOfChatterUsers; i++){
            
            User u = new User();
            u.FirstName = 'Passport';
            u.LastName = 'User-' + i;
            u.Alias = 'pus' + i;
            u.Email = 'passport.user'+i + '@makepositive.com';
                u.username = 'passport.user'+i + '@makepositive.com';
            u.CommunityNickname = 'passport.user' + i;
            u.emailencodingkey = 'UTF-8';
            u.languagelocalekey = 'en_US';
            u.localesidkey = 'en_GB';
            u.timezonesidkey = 'Europe/London';
            u.ProfileId = p.Id;
            newUsersList.add(u);
        }
        
        insert newUsersList;    
        
        List<CollaborationGroup> lstPublicGroups = createGroups('Public', noOfPublicGroups);
        List<CollaborationGroup> lstPrivateGroups = createGroups('Private', noOfPrivateGroups);
        
        CollaborationGroup allUsersGroup = assignAllUsersToPublicGroup(newUsersList);
        
        followUsers(newUsersList);
        
        return  newUsersList;
    }
    
    /**************************************************************************** 
    Method getChatterUsers will retreive all the passport chatter users.
    ****************************************************************************/
    public List<User> getChatterUsers()
    {
        List<User> lstChatterUsers = [select id, Name, FirstName, LastName, Alias, Email, username, ProfileId From User where email Like '%passport%'];
        
        return lstChatterUsers;
    }
    
    /**************************************************************************** 
    Method deleteChatterUsers will delete all the passport chatter users.
    ****************************************************************************/
    /*
    
    // Delete operation not allowed on users so may be for clean up we will deactivate the users.
    
    public void deleteChatterUsers(List<User> lstChatterUsers)
    {
        delete lstChatterUsers;
    }
    */


    /**************************************************************************** 
    Method createGroups will create the Public/ Private groups.
    ****************************************************************************/
    private List<CollaborationGroup> createGroups(string groupType, Integer noOfGroups)
    {
        List<CollaborationGroup> newGroupsList = new List<CollaborationGroup>();
        
        //Select c.SmallPhotoUrl, c.OwnerId, c.Name, c.MemberCount, c.InformationTitle, c.InformationBody, c.Id, c.HasPrivateFieldsAccess, c.FullPhotoUrl, c.Description, c.CollaborationType, c.CanHaveGuests From CollaborationGroup c
         
        for(integer i = 0; i < noOfGroups; i++){
            
            CollaborationGroup g = new CollaborationGroup();
            g.Name = groupType + ' Group-' + i;
            g.Description = groupType + ' Group-' + i;
            g.CollaborationType = groupType;
            newGroupsList.add(g);
        }
        
        insert newGroupsList;   
        
        return  newGroupsList;
    }
    
    /**************************************************************************** 
    Method assignUsersToGroups will assign the chatter users to the public and 
    private chatter groups.
    ****************************************************************************/
    private void assignUsersToGroups(List<User> lstChatterUsers, List<CollaborationGroup> lstPublicGroups, List<CollaborationGroup> lstPrivateGroups)
    {
        List<CollaborationGroupMember> newGroupMembersList = new List<CollaborationGroupMember>();

        // Assign users to public Group
        for(CollaborationGroup g : lstPublicGroups)
        {
            for (Integer i = 0; i < 100; i++)
            {
                Integer rand = Math.round(Math.random() * 2000);    // TO DO: Check the logic for this random number to be in 1 - 2000
                
                User u = lstChatterUsers[rand];
    
                // Select c.NotificationFrequency, c.MemberId, c.Id, c.CollaborationGroupId From CollaborationGroupMember c
    
                CollaborationGroupMember gm = new CollaborationGroupMember();
                
                gm.MemberId = u.Id;
                gm.CollaborationGroupId = g.Id;
                
                newGroupMembersList.add(gm);    
                
            }
        }

        // Assign users to Private Group
        for(CollaborationGroup g : lstPrivateGroups)
        {
            for (Integer i = 0; i < 100; i++)
            {
                Integer rand = Math.round(Math.random() * 2000);    // TO DO: Check the logic for this random number to be in 1 - 2000
                
                User u = lstChatterUsers[rand];
    
                // Select c.NotificationFrequency, c.MemberId, c.Id, c.CollaborationGroupId From CollaborationGroupMember c
    
                CollaborationGroupMember gm = new CollaborationGroupMember();
                
                gm.MemberId = u.Id;
                gm.CollaborationGroupId = g.Id;
                
                newGroupMembersList.add(gm);    
                
            }
        }

        insert newGroupMembersList;
    }
    
    /**************************************************************************** 
    Method assignAllUsersToPublicGroup will create a ALL Public Group and assign
    all the chatter users to it.
    ****************************************************************************/
    private CollaborationGroup assignAllUsersToPublicGroup(List<User> lstChatterUsers)
    {
         
        CollaborationGroup g = new CollaborationGroup();
        g.Name = 'All Public Group';
        g.Description = 'All Public Group';
        g.CollaborationType = 'Public';
        
        insert g;   

        List<CollaborationGroupMember> newGroupMembersList = new List<CollaborationGroupMember>();
        
        for (User u : lstChatterUsers)
        {
            // Select c.NotificationFrequency, c.MemberId, c.Id, c.CollaborationGroupId From CollaborationGroupMember c
            CollaborationGroupMember gm = new CollaborationGroupMember();
            
            gm.MemberId = u.Id;
            gm.CollaborationGroupId = g.Id;
            
            newGroupMembersList.add(gm);    
        }
        
        insert newGroupMembersList;
        
        return g;
    }
    
    /**************************************************************************** 
    Method followUsers will follow the chatter users to follow another 20 users
    ****************************************************************************/
    private List<EntitySubscription> followUsers(List<User> lstChatterUsers)
    {
        
        List<EntitySubscription> lstEntitySubscription = new List<EntitySubscription>();
        
        for (User u : lstChatterUsers)
        {
            for (Integer i = 0; i < 20; i++)
            {
                // Select e.SubscriberId, e.ParentId, e.Id From EntitySubscription e

                Integer rand = Math.round(Math.random() * 2000);    // TO DO: Check the logic for this random number to be in 1 - 2000
                
                User follower = lstChatterUsers[rand];

                EntitySubscription es = new EntitySubscription();
                
                es.ParentId = u.Id;
                es.SubscriberId = follower.Id;
                
                lstEntitySubscription.add(es);  
            }
        }
        
        insert  lstEntitySubscription;
        
        return lstEntitySubscription;
    }
}