using UnityEngine;
using System.IO;
using System.Net;


public static class SaveManager 
{
    public static string directory = "/Assets/Save/";
    public static string fileName = "MyData.txt";
    
    
    public static void Save(SaveObject so){
        
        string dir = Application.persistentDataPath + directory;   
        
        if(!Directory.Exists(dir))
            Directory.CreateDirectory(dir); 

         string json = JsonUtility.ToJson(so);
         File.WriteAllText(dir+ fileName, json);

;    }


    public static SaveObject Load(){
       
        string fullPath = Application.persistentDataPath + directory + fileName;
       //set to new save oibject remeber SaveObejct Path.
       SaveObject so = new SaveObject();
        //guard clause is simple here it states
        //if the variable field you name exist then execute and if not then debug error.
        if (File.Exists(fullPath)){
            string json = File.ReadAllText(fullPath);
            //convert into save object format where type generic is used to inform constructor data into json
            so = JsonUtility.FromJson<SaveObject>(json);
        }
        else{
            Debug.Log("Save file does not exist");
        }
        //of course the goal to get the so in a way that can provide the result we have return so;
        return so;
    }
 
}
