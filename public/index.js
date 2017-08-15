(function() {

    const Article = (props) => <li>
        <p>Title: { props.item.title }, Body: { props.item.body }</p>
    </li>;

    const MenuItem = (props) => {
        return <li>
            <p style={{color:(!props.item.has_articles_in_branch?'red':'black')}} >{ props.item.name }</p>
            <ul>{
                props.item.children.map((e,i) => {
                    if (e.class == "menuitem" && (e.has_articles_in_branch || props.editing)) {
                        return <MenuItem editing={ props.editing } item={e} key={i} />
                    } else if (e.class == "article") {
                        return <Article item={e} key={i} />
                    }
                })
            }</ul>
        </li>
    }

    class Menu extends React.Component {
        constructor(props) {
            super(props);
            this.state = {
                root: { name:"", children: [] },
                editing: false
            }
        }

        componentWillMount() {
            fetch(`/menu/1`)
                .then( result => {
                    return result.json();
                })
                .then( menu => {
                    this.setState({
                        root: menu,
                        editing: false
                    });
                });
        }

        render() {
            return <div>
                <button onClick={
                    () => this.setState({ editing: !this.state.editing })
                } >{this.state.editing ? "save" : "edit"}</button>
                <ul>
                   <MenuItem editing={ this.state.editing } item={ this.state.root }  />
                </ul>
            </div>
        }
    }

    ReactDOM.render(
        <Menu />,
        document.getElementById('list')
    );
})();
