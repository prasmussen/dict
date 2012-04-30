dict v6
====

##Query
* All queries is sent as a regex to the backend. By default the query will get transformed to: '^&lt;query&gt;.*'
* The prefixed '^' can be circumvented by putting the query inside two slashes: '/&lt;query&gt;/'

#####Examples
* Find words with 30 or more characters: [^ -]{30,}$
* Find words ending in 'dicate': /dicate$/
* Find words containing 'bear': /bear/

##Keyboard shortcuts
<table>
    <tr>
      <td>F1 - F12</td>
      <td>Quick jump to a language</td>
    </tr>
    <tr>
      <td>Tab</td>
      <td>Jump to the next language</td>
    </tr>
    <tr>
      <td>Shift-Tab</td>
      <td>Jump to the previous language</td>
    </tr>
    <tr>
      <td>Arrow Down</td>
      <td>Next page</td>
    </tr>
    <tr>
      <td>Arrow Up</td>
      <td>Previous page</td>
    </tr>
    <tr>
      <td>Escape</td>
      <td>Clear input field</td>
    </tr>
</table>