`Serialization`
This is the process whereby an object or data structure is translated into a format suitable for transferral over a network or storage.
In JavaScript for example, you can serialize an oject into a JSON string by calling the function `JSON.stringify`
CSS values are serialized by calling the function `CSSStyleDeclaration.getPropertyValue()`

`Instance Public Method`
`rescue_from`
Receives a series of exception classes or class names and a trailing :with option with the name of a method or a Proc object to be called to handle them. 
Alternatively a block can be given. 

`status: :not_found`
404 error
The server cannot find the requested resource

`fetch`
The only thing that causes fetch to return a rejected promise and not a fulfilled promise is a network error 
Any kind of response from the server counts as a resolved promise. 
In order to make sure our code doesn't break if something occurs on the server we check if the response is OK
and we setup our API to send back a status code that isn't OK. 

`$ rails new rails-js-todolist-backend -–api -–database=postgresql -T`

`$ rails new rails-js-todolist-backend -–api -–database=postgresql -T`
--api  Specifying  api framework ?? 
--database=postgresql  We're using postgresql because SQLite is only local 
-T skips mini test 

`ApplicationController < ActionController::API`
We're inheriting from ActionController::API instead of ActionController::Base because we don't need middleware, cookies, etc. 
We are using it specifically for API. 

`gem rack-cors`
This is a gem that enables cross origin resource sharing 
If this gem is not enabled, the rails server will only respond to requests that come from the same origin 

```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'   #Specifying what we want to allow. * means everything. 

    resource '*',
      headers: :any,
      expose: ["Authorization"],   #Exposing a header called "Authorization, we are specifying where the JSON web tokens are going to be included in requests and allow the devise the recognize the currently logged in user. 
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end


#Added 3 gems 
gem 'devise'    #Creates routes related to authentication 
gem 'devise-jwt'
gem 'fast_jsonapi'
```
Install devise 
`rails generate devise:install`  

Added these to development.rb 
Set to an empty array because we don't need devise to do any redirects, we are using it as an api only mode. 
`config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }`
`config.navigational_formats = []`  

Generate The User Model 
`rails generate devise User`
Creates migration, model and routes 

If you are using postgresql you will need to run: 
`rails db:create`
`rails db:migrate` 

If you don't have postgres installed, you can get it here: 
http://www.postgresql.com 


Generating Controllers (includes comments)
`rails g devise:controllers users -c sessions registrations`

`super keyword`
```rb
def new
    super  
end 
``` 
If we see the super keyword in a class, it means that we are calling the method as it's defined in the superclass. 
The superclass is where it's inheriting from. for example Devise::RegistrationsController. 
This allows us to add without losing information. 

`respond_to :json`
Specify that the devise controllers will be responding to JSON requests   


```rb
Rails.application.routes.draw do
  resources :tasks
  resources :todo_lists
  devise_for :users, path: '', path_names: {     
      #removing the path "" so we can remove routes starting with users and have it start with login logout and signup
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end


config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.fetch(:secret_key_base) 
    # Fetching the :secret_key_base from our encrypted credentials file. With the Rails 6 App this will be created by default. This is the secret that will be used to sign in all of the tokens. 
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 30.minutes.to_i  
    # Expiration time for the token is 30 minutes. 
end


# REVOCATION STRATEGY 

class AddJtiToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :jti, :string, null: false
    add_index :users, :jti, unique: true
  end
end

# To add this, we can run 
# rails g migration addJtiToUsers jti:string:index:unique 

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher      #add this line to configure the User model. 
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :todo_lists #We're not using has_many through: because we added references 
  has_many :tasks
end

```
After that's complete run 
`rails db:migrate`

Generate Serializer For Users 
`rails generate serializer user id email created_at` 

```rb 
class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :email, :created_at
end

class Users::SessionsController < Devise::SessionsController
  respond_to :json    
  private

  def respond_with(resource, _opts = {})    
    render json: {
    status: {code: 200, message: 'Logged in successfully.'},
    data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }

# To make use of our UserSerializer we go into the SessionsController and make a response_with method that will tell devise that when we get a new registration to respond with json.  
# Resource is a stand in for the user. If there is a successful registration we give a successful response with a 200 status code and get some user data back. If it wasn't successful registration send an error message. This will help us tell the difference between a successful login or not.   
  end
  
  def respond_to_on_destroy
    if current_user 
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: { 
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  private  
  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: {code: 200, message: 'Logged in sucessfully.'},
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
# We create a new instance of the serializer. 
# We use the method serializable_hash to pull out the data key and all of the attributes that come with the serializer. This is modifying what we normally see from the fast json api. It allows us to show just the information that we want to. 


}
    else
      render json: {
        status: {message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"}
      }, status: :unprocessable_entity
    end
  end
end

before_action :authenticate_user!    #Add this line to any controller to authenticate the user 
#To test it, you can try this in the browser console
fetch('http://localhost:3000/signup', {     
    #Sending a post request to sign up via the registration controller create route.  
    method: 'post',    
    headers: {
      'Content-Type': 'application/json'   #Specifying in the header that we want JSON back 
    },
    body: JSON.stringify(
        { 
            "user": {               #Specifying what the user and password is 
                "email" : "test@test.com",
                "password" : "password"
            }
        }
    )
})
  .then(res => {  #If the response is ok (200 status code in the response) then we log the authorization header.  
    if(res.ok) {
      console.log(res.headers.get('Authorization'))
      localStorage.setItem('token', res.headers.get('Authorization'))  
      #Storing the token in the browser's local storage. When we send additional requests we can send it again. This is similar to the cookie authentication method. The token is used to recognized who the user is and respond accordingly.   
      return res.json()  #Will return with JSON if it's successful otherwise it will return an error 
    } else {
      throw new Error(res);
    }
  })
  .then(json => console.dir(json))  #Successful Response 
  .catch(err => console.error(err))   #Failed Respose produces an error 
```


# Rails Javascript Todo List App Backend 

`TodoList Model` 
    belongs_to :user 
    has_many :tasks 

t.string :name 
t.references :user 

`Task Model`  
    belongs_to :user
    belongs_to :todo_list 

t.string :name 
t.text :notes 
t.boolean :complete 
t.references :user 
t.references :todo_list 


This will be a one to many relationship. 
When we will be building our Front End side of the application, all of the records that we will create are going to belong to the current user, which is the first user we have created User.first 
We will focus on the app from one user's perspective, we're building it in such a way that if we have the ability to switch users all of the api end points will respond with the correct data because we have been using current user the whole time. 

# Scaffold
If you have an api only app, it's a good idea to use a scaffold generator. 
It will be fully restful and have no mistakes. 
Make sure to have a plan. 

`rails g scaffold TodoList name user:references` 
When we run this command we will get the following: 

`todo_lists_controller.rb`    
filled out with the controller actions along with strong parameters 
Some changes are still necessary because we want to use serializers  

```ruby 
`todo_list.rb` 
class TodoList < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end

`routes.rb` 
Rails.application.routes.draw do
  resources :tasks
  resources :todo_lists
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end

`20201230135017_create_todo_lists.rb`
class CreateTodoLists < ActiveRecord::Migration[6.0]
  def change
    create_table :todo_lists do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

`Then we run rails db:migrate to commit it to the schema` 
`rails g scaffold Task name notes:text complete:boolean user:references todo_list:references`  


`tasks_controller.rb`    
# filled out with the controller actions along with strong parameters 
# Some changes are still necessary because we want to use serializers  

class Task < ApplicationRecord
  belongs_to :user
  belongs_to :todo_list

  validates :name, presence: true
  validates :completed, inclusion: { in: [true, false] }
end

`routes.rb` 
Rails.application.routes.draw do
  resources :tasks
  resources :todo_lists
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end

`20201210235217_create_tasks.rb` 
class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :notes
      t.boolean :complete
      t.references :user, null: false, foreign_key: true
      t.references :todo_list, null: false, foreign_key: true

      t.timestamps
    end
  end
end

`seeds.rb`
user = User.first 
study_tasks = user.todo_lists.find_or_create_by(name: "Study Tasks")
task_1 = user.tasks.find_or_create_by(name: "learn about promises", completed: false, todo_list_id: study_tasks.id)
```
```html 

<!DOCTYPE html>     
<!-- Styling with Tailwind CSS -->
<html lang="en">   
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Todo List</title>
  <link href="https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css" integrity="sha512-+4zCK9k+qNFUR5X+cKL9EIR+ZOhtIloNl9GIKS57V1MyNsYpYcUrUeQc9vNfzsWfV28IaLL3i96P9sdNyeRssA==" crossorigin="anonymous" />
</head>
<body>
  <div class="container mx-auto sm:grid grid-cols-3 gap-4 my-4">
    <!-- Outer container that's centered.  mx-auto auto horizontal margin   grid styling  gap 4 vertical margin 4 space between the top and bottom of the screen. -->
    <section id="flash" class="col-span-3 h-10 px-4 py-2 opacity-0 transition-all duration-700 ease-in-out"></section>
    <section id="todoListsContainer" class="px-4 bg-blue-100 sm:min-h-screen rounded-md shadow">
      <!-- todoListsContainer section has horizontal padding blue background and minimum height of the screen, it will fill the whole window. We made it rounded with a shadow in the background. -->


      <h1 class="text-2xl semibold border-b-4 border-blue">Todo Lists</h1>
      <!-- Header for todo lists with double xl font size that's semibold. We have a little border that's blue that's under Todo Lists and under Tasks.   -->

      <form id="newTodoList" class="flex mt-4">

        <input type="text" class="flex-1 p-3" name="name" placeholder="New List" /> 
        <button type="submit" class="flex-none"><i class="fa fa-plus p-4 z--1 bg-green-400"></i></button>
        <!-- Making sure the input fills the whole container -->
        <!-- flex 1 will grow the whole container. flex-none will not.  -->
        <!-- fa is font awesome. We are making sure that the clickable area is bigger, the icon will have a click event listener attached to it.  -->
</form>
      <ul id="lists" class="list-none">
        <!-- We will create the list items via JavaScript by connecting to our API. We will look in our backend API and see what's in there, and we will use what's in the API to populate this list.  Similar with tasks.  -->
      </ul>
    </section>
    <section id="tasksContainer" class="px-4 bg-blue-100 sm:min-h-screen col-span-2 rounded-md shadow">
      <h1 class="text-2xl semibold border-b-4 border-blue">Tasks</h1>
      <form id="newTask" class="flex mt-4">
        <input type="text" class="block flex-1 p-3" placeholder="New Task" />
        <button type="submit" class="block flex-none"><i class="fa fa-plus p-4 z--1 bg-green-400"></i></button>
      </form>
      <ul id="tasks" class="list-none">
        <li class="my-2 px-4 bg-green-200 grid grid-cols-12">
          <a href="#" class="py-4 col-span-10">My First Task</a>
          <a href="#" class="my-4 text-right"><i class="fa fa-pencil-alt"></i></a>
          <a href="#" class="my-4 text-right"><i class="fa fa-trash-alt"></i></a>
        </li>
      </ul>
    </section>
  </div>
  <script src="js/models.js"></script>
  <script src="js/listeners.js"></script>
</body>
</html>
``` 
```js
`models.js`  
class TodoList {
  constructor(attributes) {
    let whitelist = ["id", "name", "active"]
    whitelist.forEach(attr => this[attr] = attributes[attr])
  }
  /*
  TodoList.container() returns a reference to this DOM node:
  <ul id="lists" class="list-none">
  </ul>
  */
  static container() {
    return this.c ||= document.querySelector('#lists')
    //static container() returns the lists id element  
  
  }

  /*
  TodoList.all() returns a promise for the collection of all todoList objects from the API.
  It also takes those todoLists and calls render on them, generating the li DOM nodes that 
  display them, and spreading them out into the list where they'll be appended to the DOM.
  */
  static all() {
    return fetch("http://localhost:3000/todo_lists")   //fetches URL 
      .then(res => res.json()) // Returns promise for the body of the response parsed that's in JSON formatted and it converted into a data structure. 
      .then(todoListsJson => {
        this.collection = todoListsJson.map(tlAttributes => new TodoList(tlAttributes))
        let listItems = this.collection.map(list => list.render())
        this.container().append(...listItems)
        return this.collection
      })
  }
  /*
  render 
  Javascript uses the document object model (DOM) to manipulate the DOM elements. Rendering refers to showing the output in the browser. 

  TodoList.create(formData) will post the todoList to the database, take the successful 
  response and use it to create a new TodoList, add it to the collection, render it and
  insert it into the list(). If there's an error, the validation message will get added.
  */
  static create(formData) {   //formData is an object 
    return fetch("http://localhost:3000/todo_lists", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify(formData)
    })
      .then(res => {   
        if(res.ok) {
          return res.json()  
        } else {
          return res.text().then(errors => Promise.reject(errors))
        }
      })
      .then(json => {
        let todoList = new TodoList(json);
        this.collection.push(todoList);
        this.container().appendChild(todoList.render());
        new FlashMessage({type: 'success', message: 'TodoList added successfully'})
        return todoList;
      })
      .catch(error => {
        new FlashMessage({type: 'error', message: error});
      })
  }
  /*
  TodoList.findById(id) will return the TodoList object that matches the id passed as an argument.
  We'll assume here that this.collection exists because we won't be calling this method until the DOM we've clicked on an element created by one of our TodoList instances that we created and stored in 
  this.collection when the initial fetch has completed and promise callbacks have been executed.
  We're using == instead of === here so we can take advantage of type coercion 
  (the dataset property on the target element will be a string, whereas the id of the TodoList will be an integer)
  */
  static findById(id) {
    return this.collection.find(todoList => todoList.id == id)
  }

  /*
  This method will remove the contents of the element and replace them with the form we can use to edit the
  todo list. We'll also change the styling of our this.element li a little so it looks better within the list.
  <li class="my-2 bg-green-200">  
    <form class="edit-todo-list flex mt-4" data-todo-list-id=${this.id}>
      <input type="text" class="flex-1 p-3" name="name" value="${this.name} />
      <button type="submit" class="flex-none"><i class="fa fa-save p-4 z--1 bg-green-400"></i></button>
    </form>
  </li>
  */
  edit() {
    // remove the current contents of the element representing this TodoList and remove grid styles
    [this.nameLink, this.editLink, this.deleteLink].forEach(el => el.remove())
    this.element.classList.remove(..."grid grid-cols-12 sm:grid-cols-6 pl-4".split(" "))
    // if we've already created the form, all we need to do is make sure the value of
    // the name input matches the current name of the todo list
    if(this.form) {
      this.nameInput.value = this.name;
    } else {
      this.form = document.createElement('form');
      // adding the classes this way lets us copy what we'd have in our html here.
      // we need to run split(" ") to get an array of class names individually, then we 
      // call ... (the spread operator) on that array so we can spread out each element
      // as a separate argument to classList, which accepts a sequence of strings as arguments
      this.form.classList.add(..."editTodoListForm flex mt-4".split(" "));
      this.form.dataset.todoListId = this.id;
      // create name input 
      this.nameInput = document.createElement('input');
      this.nameInput.value = this.name;
      this.nameInput.name = 'name';
      this.nameInput.classList.add(..."flex-1 p-3".split(" "));
      // create save button 
      this.saveButton = document.createElement('button');
      this.saveButton.classList.add("flex-none");
      this.saveButton.innerHTML = `<i class="fa fa-save p-4 z--1 bg-green-400"></i>`

      this.form.append(this.nameInput, this.saveButton);
    }
    // add the form to the empty list item.
    this.element.append(this.form);
    this.nameInput.focus();
  }
  /*
  todoList.update(formData) will make a fetch request to update the todoList via our API, we'll take the succesful response and
  use it to update the DOM with the new name. We'll also replace the form with the original nameLink, editLink, and deleteLink 
  and restore the styles on the this.element li to their initial state. We'll also show a successful flash message at the top.
  If something goes wrong, we'll hold off on removing the form and instead raise a flash error message at the top allowing the 
  user to try again.
  */
  update(formData) {
    return fetch(`http://localhost:3000/todo_lists/${this.id}`, {
      method: 'PUT',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify(formData)
    })
      .then(res => {
        if(res.ok) {
          return res.json()
        } else {
          return res.text().then(errors => Promise.reject(errors))
        }
      })
      .then(json => {
        //update this object with the json response
        Object.keys(json).forEach((key) => this[key] = json[key])
        // remove the form
        this.form.remove();
        // add the nameLink edit and delete links in again.
        this.render();
        new FlashMessage({type: 'success', message: 'TodoList updated successfully'})
        return todoList;
      })
      .catch(error => {
        new FlashMessage({type: 'error', message: error});
      })
  }

  delete() {
    let proceed = confirm("Are you sure you want to delete this list?");
    if(proceed) {
      return fetch(`http://localhost:3000/todo_lists/${this.id}`, {
        method: 'DELETE',
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        }
      })
        .then(res => {
          if(res.ok) {
            return res.json()
          } else {
            return res.text().then(errors => Promise.reject(errors))
          }
        })
        .then(json => {
          //update this object with the json response
          let index = TodoList.collection.findIndex(list => list.id == json.id);
          TodoList.collection.splice(index, 1);
          this.element.remove();
        })
        .catch(error => {
          new FlashMessage({type: 'error', message: error});
        })
    }
  }

  /*
  <li class="my-2 px-4 bg-green-200 grid grid-cols-12 sm:grid-cols-6">
    <a href="#" class="py-4 col-span-10 sm:col-span-4">My List</a>
    <a href="#" class="editList my-4 text-right"><i class="fa fa-pencil-alt"></i></a>
    <a href="#" class="deleteList my-4 text-right"><i class="fa fa-trash-alt"></i></a>
  </li>
  */
  render() {
    this.element ||= document.createElement('li');

    this.element.classList.add(..."my-2 pl-4 bg-green-200 grid grid-cols-12 sm:grid-cols-6".split(" "));
    this.nameLink ||= document.createElement('a');
    this.nameLink.classList.add(..."py-4 col-span-10 sm:col-span-4 cursor-pointer".split(" "));
    this.nameLink.textContent = this.name;
    // only create the edit and delete links if we don't already have them
    if(!this.editLink) {
      this.editLink = document.createElement('a');
      this.editLink.classList.add(..."my-1".split(" "));
      this.editLink.innerHTML = `<i class="fa fa-pencil-alt editTodoList p-4 cursor-pointer" data-todo-list-id="${this.id}"></i>`;
      this.deleteLink = document.createElement('a');
      this.deleteLink.classList.add(..."my-1".split(" "));
      this.deleteLink.innerHTML = `<i class="fa fa-trash-alt deleteTodoList p-4 cursor-pointer" data-todo-list-id="${this.id}"></i>`;
    }

    this.element.append(this.nameLink, this.editLink, this.deleteLink);
    return this.element;
  }

}

class Task {
  constructor(attributes) {
    let whitelist = ["id", "name", "todo_list_id", "complete", "due_by"]
    whitelist.forEach(attr => this[attr] = attributes[attr])
  }

  static container() {
    return this.c = document.querySelector("#tasks")
  }
}

class FlashMessage {
  constructor({message, type}) {
    this.error = type === "error";
    this.message = message;
    this.render()
  }

  container() {
    return this.c ||= document.querySelector("#flash")
  }

  render() {
    this.container().textContent = this.message;
    this.toggleDisplay();
    setTimeout(() => this.toggleDisplay(), 5000);
  }

  toggleDisplay() {
    this.container().classList.toggle('opacity-0');
    this.container().classList.toggle(this.error ? 'bg-red-200' : 'bg-blue-200')
    this.displayed = !this.displayed;
  } 
}
```

`We have two classes:`  
TodoList 
Task  

`We have to main files where our JavaScript is going to live`
models.js   
listeners.js 

`constructor(attributes)`
In the constructor we have a whitelisted group of attributes, we iterate over the whitelist and for each attribute we pull out the value of this.attributes object that we use to build a new todo and store it as a property of this object which is the object we're creating when we make a new to do list. 

`This would give us a todo list object with these attributes. Example:`  
new TodoList({id: 1, name: "My Todo List", "active": false})

 
`TodoList.container()` 
`static container()`
Returns a reference to the DOM node that everything is inside of.  

```rb
static list(){
  return this.l ||= document.querySelector("#lists")
}
```
`static list is used more often` 
`||=`
The reason we're doing this is we don't want to make another query to the DOM every time we call list. We do it the first time and then we capture the DOM node as a reference in the l property on the class. 
When you refer to "this" in a static method we are referring to the class itself. This is true most of the time. 
We can container or list on the to do list class, this.l  is same as Todolist.l 
We are storing a property on the class itself called l that refers to the element with the id of #lists
`<ul id="lists" class="list-none">`    
We have a reference to this element stored in the class itself. It can be referenced anywhere in the class via the list method. 
This provides the ability to add nodes to this DOM node. 
From the class itself we have a connection to the DOM, when we get new objects we create them or update them, we have the ability to manipulate the DOM without having to do additional queries. 

`static container()`
Storing the list of tasks 


`API Controller Notes`
In the API Controller we return back an array of JavaScript objects. On the front end the Promise resolves. 
We will parse the body of the response as JSON chain on another then callback to take back the property formatted data. 

When you make a request to the API you get back a string in JSON format as the body of the response. When you call JSON on it, it will return a promise for the body parsed as a JavaScript data structure. 
If we have a string with brackets we will end up with an array. 

`render`
render is a method that takes the object and returns the DOM node that we want to put into the page. 

`TodoList.all`
Will return a promise for all of the todo_list objects that we get from fetching to /todo_lists 
This collection will be stored locally in TodoList.collection so we can reference it after the initial call to TodoList.all() which will occur at the DOMContentLoaded event. 

```js
document.addEventListener('DOMContentLoaded', function(e) {
  TodoList.all()
})

/*
We are calling events on the document because we're relying on all events propogating up to the document. 
We capture the target of the event and use that to determine how we should respond when that particular thing gets clicked on. 
Rather than having separate click event listeners all of the things that we want to handle clicks on, we have a single click event listener at the document and check whatever the target of the event is, (what the CSS selector was that matched it) and then call the right method. 


TodoList.all()
returns a promise for the collection of all todoList objects from the API.
It also takes those todoLists and calls render on them, generating the li DOM nodes that 
display them, and spreading them out into the list where they'll be appended to the DOM.

fetch
Fetch always returns a promise for a response object 
Fetch very rarely returns a rejected promise. If we want to be able to do error handling we need to check in the response for an ok property. Response.ok (200-299, boolean response)


*/

static all() {
  return fetch("http://localhost:3000/todo_lists")   //fetches URL 
    .then(res => res.json()) // Returns promise for the body of the response parsed that's in JSON formatted and it converted into a data structure. 
    .then(todoListsJson => {
      this.collection = todoListsJson.map(tlAttributes => new TodoList(tlAttributes))  
      let listItems = this.collection.map(list => list.render())   
      this.container().append(...listItems)  //Spreading it so we can get it as a list of separate arguments q
      return this.collection
    })
  }

  static create(formData) {   //formData is an object 
    return fetch("http://localhost:3000/todo_lists", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify(formData)

  
    })
      .then(res => {   
        if(res.ok) {
          return res.json()  
        } else {
          return res.text().then(errors => Promise.reject(errors))
        }

      })
      .then(json => {
        let todoList = new TodoList(json);
        this.collection.push(todoList);
        this.container().appendChild(todoList.render());
        new FlashMessage({type: 'success', message: 'TodoList added successfully'})
        return todoList;


      })
      .catch(error => {
        new FlashMessage({type: 'error', message: error});
      })
  }

```
`JSON.stringify()`
The JSON.stringify() method converts a JavaScript object or value to a JSON string, 
optionally replacing values if a replacer function is specified or optionally including only the specified properties if a replacer array is specified.

`Promise.reject()`
The Promise.reject() method returns a Promise object that is rejected with a given reason.

`error`
The error message comes from the API  

`res.text`
The reason we use res.text and not res.json is because res.text also returns a promise. 
No matter what the format originally was, we can see the error in plain text. 

`render`
Javascript uses the document object model (DOM) to manipulate the DOM elements. Rendering refers to showing the output in the browser.
We will also use render to return the DOM element. The list item tag with the data from the API in it.  

 ```rb

# Serializer
# rails g serializer TodoList id name


class TodoListSerializer
  include FastJsonapi::ObjectSerializer 
  attributes :id, :name
end

class TodoListsController < ApplicationController
  before_action :set_todo_list, only: [:show, :update, :destroy]


  def index     # GET /todo_lists 
    @todo_lists = current_user.todo_lists  
    render json: TodoListSerializer.new(@todo_lists).serializable_hash[:data].map{|hash| hash[:attributes]}   #This is how it's used. 
# Before the serializer we had an array of objects and after we have a data property pointing to an array of objects. Each object has id, type and attribute. We need to things in attributes. 
# serializable_hash 
# returns a serialized hash of your object.
# We use the brackets method [] to access the key in a hash. 
  end
```

`TodoListArray`
TodoListArray is an Array of objects. Each one of the objects can be used to make a new to do list instance of the class that we have. 
We want to take the array of objects and make it an array of instances for this we use the map method. 

todoListArray.map(attrs => new TodoList(attrs)) 




`Arrow Functions vs. Regular Functions`
The "this" Arrow Functions have the same context. They have the same context as when they are defined. 
Regular Functions do not retain the same context. 

Functions like .filter .map .ForEach are regular keyword functions defined on the array prototype which means any instance of array object can receive those methods and within the method function call this will refer to the particular array that you called the function on. 

`this.collection`
We store the collection we have created in this.collection 
The collection is the todo list we got from the api initially
collection is a property of the class 


```js
render() {
    this.element ||= document.createElement('li');  

    this.element.classList.add(..."my-2 pl-4 bg-green-200 grid grid-cols-12 sm:grid-cols-6".split(" "));
    this.nameLink ||= document.createElement('a');
    this.nameLink.classList.add(..."py-4 col-span-10 sm:col-span-4 cursor-pointer".split(" "));
    this.nameLink.textContent = this.name;
    // only create the edit and delete links if we don't already have them
    if(!this.editLink) {
      this.editLink = document.createElement('a');
      this.editLink.classList.add(..."my-1".split(" "));
      this.editLink.innerHTML = `<i class="fa fa-pencil-alt editTodoList p-4 cursor-pointer" data-todo-list-id="${this.id}"></i>`;
      this.deleteLink = document.createElement('a');
      this.deleteLink.classList.add(..."my-1".split(" "));
      this.deleteLink.innerHTML = `<i class="fa fa-trash-alt deleteTodoList p-4 cursor-pointer" data-todo-list-id="${this.id}"></i>`;
    }

    this.element.append(this.nameLink, this.editLink, this.deleteLink); 
    // We're appending multiple nodes, a collection.  It's important that we do it this way because we have separate references  
    return this.element;
    //returning the element   
  }
``` 
`Element.classList`
The Element.classList is a read-only property that returns a live DOMTokenList collection of the class attributes of the element. 
This can then be used to manipulate the class list. Also, using classList is a convenient alternative to accessing an element's list of classes as a 
space-delimited string via element.className.

`Syntax for Element.classList`
const elementClasses = elementNodeReference.classList;

`Returns`
A DOMTokenList representing the contents of the element's class attribute. 
If the class attribute is not set or empty, it returns an empty DOMTokenList, i.e. a DOMTokenList with the length property equal to 0.
The DOMTokenList itself is read-only, although you can modify it using the add() and remove() methods.

`this.nameLink`  ?? 
This is a property name we assigned to the DOM node that will display the name as a link  

`textContent`
textContent gets the content of all elements, including script and style elements. 
returns every element in the node. 

`innerText`
innerText only shows “human-readable” elements. 
innerText is aware of styling and won't return the text of “hidden” elements.

`innerHTML`
innerHTML property returns the text, including all spacing and innerelement tags. 
Do not use innerHTML= when it involves user input because it opens up a vulnerability with scripts 

`Node.appendChild()`
The Node.appendChild() method adds a node to the end of the list of children of a specified parent node. 
If the given child is a reference to an existing node in the document, appendChild() moves it from its current position to the new position 
(there is no requirement to remove the node from its parent node before appending it to some other node).

`ParentNode.append()`
The ParentNode.append() method inserts a set of Node objects or DOMString objects after the last child of the ParentNode. 
DOMString objects are inserted as equivalent Text nodes.

`Differences from Node.appendChild():` 

`ParentNode.append()` 
Allows you to also append DOMString objects, whereas Node.appendChild() only accepts Node objects.
Has no return value, whereas Node.appendChild() returns the appended Node object.
Can append several nodes and strings, whereas Node.appendChild() can only append one node

`Spread Operator (...)`
The spread operator is a useful and quick syntax for adding items to arrays, combining arrays or objects, and spreading an array out into a function’s arguments.
this.editLink.classList.add(..."my-1".split(" "))

`split()`
The split() method is used to split a string into an array of substrings, and returns the new array.
If an empty string ("") is used as the separator, the string is split between each character.
The split() method does not change the original string.

`flat()`
THe flat() method creates a new array with all sub-array elements concetenated into it recursively up to the specific depth
```
```

```js 

static all() {
  return fetch("http://localhost:3000/todo_lists")   //fetches URL 
    .then(res => res.json()) // Returns promise for the body of the response parsed that's in JSON formatted and it converted into a data structure. 
    .then(todoListsJson => {
      this.collection = todoListsJson.map(tlAttributes => new TodoList(tlAttributes))  
      let listItems = this.collection.map(list => list.render())   
      this.container().append(...listItems)  
      //We have an array of 5 listItem elements, by spreading it we are turning it into 5 separate elements which are separated by commas. 
      //Instead of it being one array we have 5 separate elements. 
      //Spreading it so we can get it as a list of separate arguments. 
      return this.collection
      //Returning a promise for the collection 
    })
  }

``` 


In the render() having references to these objects and not having to keep doing queries is part of the strenght. 
Our JavaScript Model object knows about the data stored in the DB but it also knows about how that data is being displayed. 
We are storing references to the DOM Node that's displaying the information from the DB. 
If we need to manipulate the DOM node, we don't have to do a query to do it because we have a references that has access to it. 

The class takes responsibility for updating the database if necessary and then using the Database API response to update the DOM accordingly. 

`The idea is that if you need access to something you have 2 main places you store it` 
Store it at the class level as a property of the class if it's something that needs to be accessed accross different instances 
Store it at the instance level, via this.something   

`e.target.querySelectorAll("input")`
Provides a node list with all of your inputs 
If each of the inputs has a name, we could use the name to build form data
It's sometimes simpler to target an individual one 

The target of a submit event will always be the form that you submitted 
Cutting out repetition by naming your inputs. 
Make sure your input names match the methods and attributes you want to set on the model object you're creating. Which are usually columns in the DB where you want to insert the values into. ?? 

```js 

document.addEventListener("submit", function(e){
let target = e.target
if(target.matches("#newTodoList")){
  e.preventDefault()
let formData = {}
target.querySelectorAll("input").forEach(function(input){
  formData[input.name] = input.value;
})
}
})
```
`fetch`
In the chrome console we saw that the request has already been set, the response has already been sent too, it's an illustration of asynchronous code and the way chrome or a browser is interacting with it. 
fetch returns a promise, the promise api allows us to attach asynchronous callbacks. The browser won't process all of it or resolve until the callstack is clear. If you want to see the result of a fetch request in  a debugger the debugger has to be in the callback. This way it won't stop until all the functions that are running complete. 

`debugger`
When we hit a debugger chrome is pausing our code. The callstack still has the function in it and it hasn't returned yet. It's preventing the promise from resolving. The debugger is stopping the synchronous code from finishing.  

`to_sentence(options = {}) public`
Converts the array to a comma-separated sentence where the last element is joined by the connector word.
['one', 'two'].to_sentence          # => "one and two"
['one', 'two', 'three'].to_sentence # => "one, two, and three"

`this.container is not a function`
Although it says it's not a function we don't know what it is 
If you go into a debugger and type it in without () it will tell you what it is 
The reason we got the message is because we have defined container as a static method. A static method gets called directly on the class. In our example it's FlashMessage. 

`Defining Methods Inside Of A Class`
Every time you define a method inside of a class it's a function keyword function. 
It's context is set at call time, not at definition time.  
This was a problem with toggleMessage function. 

`setTimeout`
The first time "this" is called it's being called on the FlashMessage class. 
The second time "this" is called within setTimeout, it's being called on the Window. 
setTimeout is a method in a window object. The callback function is invoked when the Window object is in scope.  
this.toggleMessage inside of setTimeout 

`bind`
This is used to state that we want the context not to change
We could also use an arrow function to achieve a similar outcome.  

`dataset`
The dataset read-only property of the HTMLorForeignElement interface provides read/write access to custom data attributes on elements. 
It exposes a map of strings (DOMStringMap) with an entry for each data attribute. 
The dataset property itself can read, but not directly written. Instead, all write must be to the individual properties within the dataset, 
which in turn represent the data attributes. 
An HTML data attribute and it's corresponding DOM dataset.property modify their shared name according to where they are read or written. 

`example`
data-abc-def attribute corresponds to dataset.abcDef.


When we set the dataset property for todoListId to the id of that particular todoList instance the object in
what we're doing is we're adding that data attribute to the DOM node so that when we put it back in the DOM and look back at the elements tab the element we select actually has this attribute "data-todo-list-id" and it's set equal to the id of the object associated with that element's DOM node. ?? 

setter and getter ?? 

