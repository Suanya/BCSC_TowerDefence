using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Text.RegularExpressions;
public class ChuckNorris : MonoBehaviour
{
    public TextMeshProUGUI jokeText;
    public void NewJoke(){
        Joke j = ApiHelper.GetNewJoke();
         jokeText.text = j.value;

        string input = j.value;
      

      string pattern = "([A-Z])\\w[Chuck]+)";
      string replacement = "Chick";
      string result = Regex.Replace(input, pattern, replacement);
    }
}
