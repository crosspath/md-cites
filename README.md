# MdCites

This preprocessor for Markdown builds references block usable to view on screen and paper. It does not use bibtex or any other citation databases.

## Why?

I need to write and edit my dissertation splitting it onto several Markdown files and use GOST R 7.0.5-2008 (ГОСТ Р 7.0.5—2008), Russian citation format.

## Example

Example file:
```markdown
Sentence [cite: knuth].

#cite knuth: Knuth D. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. -- ISBN 0-201-89683-4.

### References

#ref
```

Output markdown file:
```markdown
Sentence [[1]](#a-knuth).


### References

1. <a name="a-knuth"></a> Knuth D. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. -- ISBN 0-201-89683-4.
```

And after parsing resulting markdown file you will get:
```
<p>Sentence <a href="#a-knuth">[1]</a>.</p>

<h3>References</h3>

<ol>
  <li><a name="a-knuth"></a> Knuth D. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). — USA: Addison-Wesley Professional, 1997. — ISBN 0-201-89683-4.</li>
</ol>
```

And it looks like this:

Sentence [[1]](#a-knuth).


### References

1. <a name="a-knuth"></a> Knuth D. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. -- ISBN 0-201-89683-4.


## Usage

Use it after [markdown-include](https://github.com/sethen/markdown-include).

    ruby md-cites.rb input_file.md output_file.md

You may split references list on parts:
```markdown
[cite: abc]
#cite abc: Source 1.

#ref

[cite: abc]
#cite abc: Source 2.

#ref
```

Result:
```markdown
[[1]](#a-abc)

1. <a name="a-abc"></a> Source 1.

[[1]](#b-abc)

1. <a name="b-abc"></a> Source 2.
```

It's usable for putting references list at the end of each chapter.

At present, this script orders references list only by mention. Well, it's good to sort it by alphabet too.
