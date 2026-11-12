# PAG resources

`pod install` in `Example/` runs `scripts/fetch-animation-resources.py PAGResources`
(copied from CYLTabBarController), which downloads the files listed in
`pag-resources.json` into `pag-ios/`: sample `.pag` files of
[libpag/pag-ios](https://github.com/libpag/pag-ios) (Apache License 2.0) and the PAG tab icons
of CYLTabBarController's Example-PAG (`tab_*.pag`, from Tencent/libpag and libpag/pag-ios, Apache
License 2.0, `LICENSE-libpag.txt`), pinned
to a commit and checked against their SHA-256. They are not kept in this
repository.
