# TemplatesHelper
- Copyright Nicholas Marques - CJR

# Como importar um Template com TemplatesHelper
**Passos**

**Criar Projeto**
```
Rails new nome_do_projeto -T --database=postgresql
```
**Rodar setup do banco**
```
Rails db:setup
```
Adicione
```
gem 'bootstrap', '~> 4.1.3'
```
e
```
gem 'jquery-rails'
```
no Gemfile e rode
```
bundle install
```
Mudar application.css para application.scss e importar bootstrap nele
```
@import bootstrap;
```
importar no application.js:
```
//= require jquery3

//= require popper

//= require bootstrap-sprockets
```

Gerar controller da home page
```
rails g controller main index
```
Colocar em routes.rb a rota raíz:
```
root to: 'main#index'
```

Criar pasta assets em vendor e colar toda pasta do template la (nesse caso o template se chama concept-master)

![Pasta em vendor/assets](https://i.imgur.com/kWMzwxU.png)

Coloque agora a index.html do template (ou qualquer página que queira converter do template, como por exemplo contact.html) na pasta to_convert do TemplatesHelper

No terminal, rode o arquivo templates_converter.rb
```
ruby templates_converter.rb
```
Siga as instruções printadas no terminal, reinicie o server e cheque por erros na aplicação.

Corrija tudo e é isso! :)
