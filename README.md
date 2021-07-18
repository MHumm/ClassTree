# ClassTree
Small application for generating class trees.

How to use?

1. Add all the units which contain the classes you want 
   to have in the tree to the project
   
2. Run it.

3. Click "Generate" button. You will receive a tree containing
   all those classes and the classes used in the generator itsself.

4. Select a node and click "Export selected node". This will create 
   a text only representation (used font here is Courier New, as it 
   contains those line characters and is monospaced).
   
5. You may select text in the memo (Ctrl-A selects all) and 
   copy it via Ctrl-C or use the "Copy to clipboard" button.
   
Here's how the outputs look like when being applied on the unaltered program:   

![Class hierarchy shown in a TTreeview](/Documentation/ClassTreeGenerator_CompleteTree.PNG "Class hierarchy shown in TTreeview")
![Class hierarchy exported into text form](/Documentation/ClassTreeGenerator_TextExport.PNG "Class hierarchy exported into text form")
   
The license for this project is Apache 2.0, see file LICENSE.
