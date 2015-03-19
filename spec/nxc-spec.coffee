{TextEditor} = require 'atom'

describe 'Language-NXC', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-ncc')

  describe "NXC", ->
    beforeEach ->
      grammar = atom.grammars.grammarForScopeName('source.nxc')

    it 'parses the grammar', ->
      expect(grammar).toBeTruthy()
      expect(grammar.scopeName).toBe 'source.nxc'

    it 'tokenizes functions', ->
      lines = grammar.tokenizeLines '''
        task something() {
          return 0;
        }
      '''

      expect(lines[0][0]).toEqual value: 'task', scopes: ["source.nxc", "storage.type.c"]
      expect(lines[0][2]).toEqual value: 'something', scopes: ["source.nxc", "meta.function.c", "entity.name.function.c"]

    describe "indentation", ->
      editor = null

      beforeEach ->
        editor = new TextEditor({})
        editor.setGrammar(grammar)

      expectPreservedIndentation = (text) ->
        editor.setText(text)
        editor.autoIndentBufferRows(0, editor.getLineCount() - 1)

        expectedLines = text.split("\n")
        actualLines = editor.getText().split("\n")
        for actualLine, i in actualLines
          expect([
            actualLine,
            editor.indentLevelForLine(actualLine)
          ]).toEqual([
            expectedLines[i],
            editor.indentLevelForLine(expectedLines[i])
          ])

      it "indents allman-style curly braces", ->
        expectPreservedIndentation """
          if (a)
          {
            for (;;)
            {
              do
              {
                while (b)
                {
                  c();
                }
              }
              while (d)
            }
          }
        """

      it "indents non-allman-style curly braces", ->
        expectPreservedIndentation """
          if (a) {
            for (;;) {
              do {
                while (b) {
                  c();
                }
              } while (d)
            }
          }
        """

      it "indents function arguments", ->
        expectPreservedIndentation """
          a(
            b,
            c(
              d
            )
          );
        """

      it "indents array and struct literals", ->
        expectPreservedIndentation """
          some_t a[3] = {
            { .b = c },
            { .b = c, .d = {1, 2} },
          };
        """
