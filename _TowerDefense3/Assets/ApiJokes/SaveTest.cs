using UnityEngine;



public class SaveTest : MonoBehaviour
{
public SaveObject so;
private void Update(){
    // if (Input.GetKeyDown(KeyCode.Space)){
    //     SaveManager.Save(so);
    // }
    // if (Input.GetKeyDown(KeyCode.Return)){
    //   so = SaveManager.Load();
    // }
}
public void SaveMyData(){
    SaveManager.Save(so);

}
public void LoadMyData(){
    so = SaveManager.Load();
}

}

