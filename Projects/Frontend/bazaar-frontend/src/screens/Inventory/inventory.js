import React, { Component } from "react";
import axios from 'axios'
import { read_cookie } from 'sfcookies';
import DataTable from 'react-data-table-component';
import { Modal, Button, Alert } from "react-bootstrap";
import { serverUrl } from '../../utils/get-url'

import "./inventory.scss";

export default class Inventory extends Component {

  constructor() {
    super();
    this.state = {
      products: [],
      name: '',
      id: '',
      brand: '',
      price: '',
      stock: '',
      detail: '',
      category: '',
      subcategory: '',
      delete: false,
      errors: [],
      isOpen: false,
      isHiddenFail: true,
      isHiddenSuccess: true,
      isHiddenDeleteSuccess: true,
      isHiddenDeleteFail: true,
      categoryList: { "": [] }
    }
    this.handleImageChange = this.handleImageChange.bind(this)

  }

/*
Loads categories and gets user's products.
*/
  componentDidMount() {
    let myCookie = read_cookie('user')
    axios.get(serverUrl + 'api/product/categories/')
      .then(res => {
        let resp = res.data;
        let categoryListTemp = {};
        let keys = [];
        for (let i = 0; i < resp.length; i++) {
          if (resp[i]["parent"] == "Categories") {
            keys.push(resp[i]["name"])
          }
        }
        for (let i = 0; i < keys.length; i++) {
          let sublist = []
          for (let j = 0; j < resp.length; j++) {
            if (resp[j]["parent"] == keys[i]) {
              sublist.push(resp[j]["name"]);
            }
          }
          categoryListTemp[keys[i]] = sublist;
        }
        categoryListTemp[''] = []
        this.setState({ categoryList: categoryListTemp })

      })
    axios.get(serverUrl + `api/product/`)
      .then(res => {
        let myProducts = res.data.filter(product => product.vendor === myCookie.user_id)
        for (let i = 0;i<myProducts.length;i++){
          myProducts[i].price = myProducts[i].price+" TL"
        }
        this.setState({ products: myProducts })
      })



  }

  /*
  handle validation while submitting. In this case, checks if the edited product's fields are valid.
  */
  handleValidation() {
    let formIsValid = true;
    let new_errors = {};
    //Name
    if (this.state.name === '') {
      formIsValid = false;
      new_errors["name"] = "Name can not be empty.";
    }
    if (this.state.brand === '') {
      formIsValid = false;
      new_errors["brand"] = "Brand can not be empty.";
    }
    if (this.state.price === '') {
      formIsValid = false;
      new_errors["price"] = "Price can not be empty.";
    }
    if (this.state.stock === '') {
      formIsValid = false;
      new_errors["stock"] = "Stock can not be empty.";
    }
    if (this.state.category === '') {
      formIsValid = false;
      new_errors["category"] = "Category can not be empty.";
    }
    this.setState({ errors: new_errors });
    return formIsValid;
  }

  /*
  Sends the necessary requests to backend. Delete or edit product. 
  */
  handleSubmit = event => {
    event.preventDefault();

    let myCookie = read_cookie('user');
    const header = { headers: { Authorization: "Token " + myCookie.token } };

    if (!this.state.delete) {

      const data = {
        name: this.state.name,
        detail: this.state.detail,
        brand: this.state.brand,
        price: this.state.price,
        stock: this.state.stock
      }

      if (this.handleValidation()) {
        axios.put(serverUrl + `api/product/` + this.state.id + "/", data, header)
          .then(res => {

            this.setState({ isHiddenSuccess: false })

            axios.get(serverUrl + `api/product/`)
              .then(res => {
                let myProducts = res.data.filter(product => product.vendor === myCookie.user_id)
                for (let i = 0;i<myProducts.length;i++){
                  myProducts[i].price = myProducts[i].price+" TL"
                }
                this.setState({ products: myProducts })
              })

          }).catch(error => {
            this.setState({ isHiddenFail: false })

          })

      } else {
        this.setState({ [this.state.hasError]: true });
      }
    } else {
      axios.delete(serverUrl + `api/product/` + this.state.id + "/", header)
        .then(res => {

          this.setState({ isHiddenDeleteSuccess: false })
          let myProducts = this.state.products.filter(product => product.id !== this.state.id)
          this.setState({ products: myProducts })
          this.closeModal()

        }).catch(error => {
          this.setState({ isHiddenDeleteFail: false })

        })
      this.setState({ delete: false })
    }

  }

  handleChange = (event) => {
    // You can use setState or dispatch with something like Redux so we can use the retrieved data
    this.setState({ [event.target.name]: event.target.value });
    //console.log(this.state.category)
  };

  handleImageChange = event => {

    event.preventDefault();
    let uploadedImage = URL.createObjectURL(event.target.files[0])
    this.setState({ image: uploadedImage })
    console.log("image: " + uploadedImage.substring(5))

  }

  rowClicked = (event) => {
    console.log(event)
    this.setState({ name: event.name })
    this.setState({ id: event.id })
    this.setState({ brand: event.brand })
    this.setState({ price: event.price.substring(0, event.price.length-3) })
    this.setState({ stock: event.stock })
    this.setState({ detail: event.detail })
    this.setState({ category: event.category["parent"] })
    this.setState({ subcategory: event.category["name"] })
    this.setState({ image: event.picture })
    this.openModal()
    console.log("category: " + event.category["parent"])
    console.log("subcategory: " + event.category["name"])
  }

  deleteProduct = () => this.setState({ delete: true });
  openModal = () => {
    this.setState({ isOpen: true });
    this.setState({ isHiddenDeleteSuccess: true })
  }
  closeModal = () => {
    this.setState({ isOpen: false })
    this.setState({ isHiddenFail: true })
    this.setState({ isHiddenSuccess: true })
    this.setState({ isHiddenDeleteFail: true })
  };

  upload = () => {
    document.getElementById("select-image").click();
  }

  render() {

    const columns = [
      {
        name: "Name",
        selector: "name",
        sortable: true
      },
      {
        name: "Brand",
        selector: "brand",
        sortable: true
      },
      {
        name: "Price",
        selector: "price",
        sortable: true,
        right: true
      },
      {
        name: "Stock",
        selector: "stock",
        sortable: true,
        right: true
      }
    ];

    let categories = Object.keys(this.state.categoryList).map(category => {
      if (category !== "") {
        return (
          <option value={category}>{category}</option>
        )
      }
    })

    let subcategories = this.state.categoryList[this.state.category].map(subcategory => {
      return (
        <option value={subcategory}>{subcategory}</option>
      )
    })

    return (
      <div className="inventory-display background">

        <Modal show={this.state.isOpen} onHide={this.closeModal}>
          <Modal.Header closeButton>
            <Modal.Title>Product Details</Modal.Title>
          </Modal.Header>
          <form className='needs-validation' onSubmit={this.handleSubmit} noValidate>

            <Modal.Body>


              <div className="col">
                <div className="image-container">
                  <img className="product-image" src={this.state.image} onClick={this.upload} />
                  <input id="select-image" type="file" name="image" className="" accept="image/jpeg image/png"
                    onChange={this.handleImageChange} hidden />
                </div>
                <div className="error">{this.state.errors["image"]}</div>

              </div>
              <Alert variant="success" hidden={this.state.isHiddenSuccess}>
                Product details updated.
              </Alert>
              <Alert variant="danger" hidden={this.state.isHiddenFail}>
                Something went wrong.
              </Alert>
              <Alert variant="danger" hidden={this.state.isHiddenDeleteFail}>
                Something went wrong.
              </Alert>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Name:</label>
                <div className="col-6">
                  <input type="text" name="name" className="form-control col" value={this.state.name}
                    onChange={this.handleChange} required />
                  <div className="error">{this.state.errors["name"]}</div>
                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Detail:</label>
                <div className="col-6">
                  <input type="text" name="detail" className="form-control col" value={this.state.detail}
                    onChange={this.handleChange} />
                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Brand:</label>
                <div className="col-4">
                  <input type="text" name="brand" className="form-control col" value={this.state.brand}
                    onChange={this.handleChange} required />
                  <div className="error">{this.state.errors["brand"]}</div>

                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Category:</label>
                <div className="col-4">
                  <select className="form-control col" name="category" id="category1" defaultValue={this.state.category}
                    onChange={this.handleChange} required>
                    <option disabled>Please Select</option>
                    {categories}
                  </select>
                  <div className="error">{this.state.errors["category"]}</div>
                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Subcategory:</label>
                <div className="col-4">
                  <select className="form-control col" name="subcategory" id="category2" defaultValue={this.state.subcategory}
                    onChange={this.handleChange}>
                    <option disabled>Please Select</option>
                    {subcategories}
                  </select>
                  <div className="error">{this.state.errors["subcategory"]}</div>
                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Price:</label>
                <div className="col-4 price-block row">
                  <input type="text" name="price" className="form-control col-8" value={this.state.price}
                    onChange={this.handleChange} required /> <div className="align-middle col-1 tl-div label-margin">TL</div>
                  <div className="error">{this.state.errors["price"]}</div>
                </div>
              </div>
              <div className="form-group row">
                <label className="col-4 align-middle label-margin">Stock:</label>
                <div className="col-3">
                  <input type="text" name="stock" className="form-control col" value={this.state.stock}
                    onChange={this.handleChange} required />
                  <div className="error">{this.state.errors["stock"]}</div>
                </div>
              </div>


            </Modal.Body>

            <Modal.Footer>
              <Button variant="primary" id="save-changes-product" type="submit">Save Changes</Button>
              <Button variant="danger" id="delete-product" type="submit" onClick={this.deleteProduct} >Delete</Button>
              <Button variant="secondary" onClick={this.closeModal}>Close</Button>
            </Modal.Footer>
          </form>

        </Modal>

        {this.state.isModalActive &&
          (
            <div >
              <Button variant="primary" onClick={this.openModal}>
                Launch demo modal
               </Button>
            </div>
          )
        }


        <Alert variant="success" hidden={this.state.isHiddenDeleteSuccess}>
          Product successfully deleted.
        </Alert>
        <DataTable
          title="My Inventory"
          columns={columns}
          data={this.state.products}
          defaultSortField="title"
          pagination
          onRowClicked={this.rowClicked}
          highlightOnHover
          pointerOnHover
          theme="custom-theme"
        />
      </div>

    );
  }
}