
type ChangeProjectOwnerBody struct {
	NewOwner *string
}

type changeProjectOwnerResponse struct {
	Schema string
}

func ChangeProjectOwner(c fuego.ContextWithBody[ChangeProjectOwnerBody]) (repository.Project, error)

type CreateProjectBody struct {
	Name   *string `json:"name" validate:"required,min=3" example:"My Project" description:"The name of the project"`
	Schema *[]byte `json:"schema" validate:"required" example:"{\"name\": {\"type\": \"string\"}}" description:"The JSON schema for the project"`
}
type createProjectResponse struct {
	Schema []byte `json:"schema"`
}

func CreateProject(c fuego.ContextWithBody[CreateProjectBody]) (repository.Project, error)

type CreateProjectPolicyBody struct {
	Policy json.RawMessage `json:"policy"`
}

func CreateProjectPolicy(c fuego.ContextWithBody[CreateProjectPolicyBody]) (repository.ProjectPolicy, error)

type CreateUserProjectAdminBody struct {
	UserID *string
}

func CreateUserProjectAdmin(c fuego.ContextWithBody[CreateUserProjectAdminBody]) (repository.UsersProject, error)

type CreateUserProjectMemberBody struct {
	UserID   *string
	PolicyID *string
}

func CreateUserProjectMember(c fuego.ContextWithBody[CreateUserProjectMemberBody]) (repository.UsersProject, error)

func DeleteProject(c fuego.ContextNoBody) (ResponseDeleteProject, error)

func DeleteProjectPolicy(c fuego.ContextNoBody) (ResponseDeleteProjectPolicy, error)

func DeleteUserProject(c fuego.ContextNoBody) (ResponseDeleteUserProject, error)

func GetProject(c fuego.ContextNoBody) (repository.Project, error)

func ListProjectPolicies(c fuego.ContextNoBody) ([]repository.ProjectPolicy, error)

func ListProjects(c fuego.ContextNoBody) ([]repository.Project, error)

func ListUsersForPolicy(c fuego.ContextNoBody) ([]UserResponse, error)

type UpdateProjectBody struct {
	Name   *string `json:"name" validate:"required,min=3" example:"My Project" description:"The name of the project"`
	Schema *[]byte `json:"schema" validate:"required" example:"{\"name\": {\"type\": \"string\"}}" description:"The JSON schema for the project"`
}

type updateProjectResponse struct {
	Schema []byte `json:"schema"`
}

func UpdateProject(c fuego.ContextWithBody[UpdateProjectBody]) (repository.Project, error)

type UpdateProjectPolicyBody struct {
	Policy *string
}

func UpdateProjectPolicy(c fuego.ContextWithBody[UpdateProjectPolicyBody]) (repository.ProjectPolicy, error)

type UpdateUserProjectBody struct {
	Role     *repository.ProjectRoles `json:"role"`
	PolicyId *uuid.UUID               `json:"project_id"`
}

func UpdateUserProject(c fuego.ContextWithBody[UpdateUserProjectBody]) (repository.UsersProject, error) 
