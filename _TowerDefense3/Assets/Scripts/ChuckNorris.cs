using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
public class ChuckNorris : MonoBehaviour
{
    public TextMeshProUGUI jokeText;
    public void NewJoke(){
        Joke j = ApiHelper.GetNewJoke();
        jokeText.text = j.value;
    }
}
