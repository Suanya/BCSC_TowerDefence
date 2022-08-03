using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Text.RegularExpressions;


[System.Serializable]
public class ChuckNorris : MonoBehaviour
{
    public TextMeshProUGUI jokeText;
    public void NewJoke(){
        Joke j = ApiHelper.GetNewJoke();
         jokeText.text = j.value;

      string replaceValueFrom = jokeText.text;
      jokeText.text = replaceValueFrom.Replace("Chuck", "Chick");

      //   string input = j.value;
      

      // string pattern = "";
      // string replacement = "";
      // string result = Regex.Replace(input, pattern, replacement);
      
    }
}
