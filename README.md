# MdCites

This preprocessor for Markdown builds references block usable to view on screen and paper. It does not use bibtex or any other citation databases.

## Why?

I need to write and edit my dissertation splitting it onto several Markdown files and use GOST R 7.0.5-2008 (ГОСТ Р 7.0.5—2008), Russian citation format.

## Example

Example file:
```markdown
Sentence [cite: knuth].

#cite knuth: *Knuth D*. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. -- ISBN 0-201-89683-4.

### References

#ref
```

Output markdown file:
```markdown
Sentence [[1]](#a-knuth).


### References

1. <a name="a-knuth"></a> *Knuth D*. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. -- ISBN 0-201-89683-4.
```

And after parsing resulting markdown file you will get:
```
<p>Sentence <a href="#a-knuth">[1]</a>.</p>

<h3>References</h3>

<ol>
  <li><a name="a-knuth"></a> <em>Knuth D</em>. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). — USA: Addison-Wesley Professional, 1997. — ISBN 0-201-89683-4.</li>
</ol>
```

And it looks like this:

Sentence [[1]](#a-knuth).


### References

1. <a name="a-knuth"></a> *Knuth D*. The Art of Computer Programming, 1: Fundamental Algorithms (3rd ed.). -- USA: Addison-Wesley Professional, 1997. — ISBN 0-201-89683-4.


## Usage

If you use [markdown-include](https://github.com/sethen/markdown-include), run `md-cites` after it.

    ruby md-cites.rb input_file.md output_file.md

## Features

### Split references

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

At present, this script orders references list only by mention.

### Extra info

You may append page numbers to a cite:
```markdown
[cite: abc, p. 123]
#cite abc: Source 1.

#ref
```

Result:
```markdown
[[1, p. 123]](#a-abc)

1. <a name="a-abc"></a> Source 1.
```

### Quotes from paraphrased sources

If you cite not the primary source (origin document) or mention somebody's ideas not from the primary source, you have to use the form `[Cited in NUMBER]` (Russian: `[Цит. по: NUMBER]`, `[Приводится по: NUMBER]`). `%s` is a placeholder for the number of the source.
```markdown
Предложение [cite: vesnin | Приводится по: %s, стр. 52].
#cite vesnin: *Веснин В*. Менеджмент. — 4-е изд. — М.: Проспект, 2012. — 616 с.

#ref
```

Result:
```markdown
Предложение [[Приводится по: 1, стр. 52]](#a-vesnin).

1. <a name="a-vesnin"></a> *Веснин В*. Менеджмент. — 4-е изд. — М.: Проспект, 2012. — 616 с.
```

## What should not be done

Add `#ref`-like command to build references list sorted by alphabet.

Cites before `#ref`-like command should look like `Sentence [Surname, year]`, `Sentence [Surname, year, page]` and `Sentence [Surname1, year1; Surname2, year2]`.

This script should not implement it because of its complexity. In this case you may use separate file with references.
